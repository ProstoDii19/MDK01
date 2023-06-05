unit main81;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  Grids, Edit;

type
  Bibl = record
    Reader: string[100];
    Date: string[100];
    Book: string[100];
    Writer: string[100];
  end; //record

  { TfMain }

  TfMain = class(TForm)
    Panel1: TPanel;
    bAdd: TSpeedButton;
    bEdit: TSpeedButton;
    bDel: TSpeedButton;
    bSort: TSpeedButton;
    SG: TStringGrid;
    procedure bAddClick(Sender: TObject);
    procedure bDelClick(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure bSortClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  fMain: TfMain;
  adres: string; //адрес, откуда запущена программа

implementation

{$R *.lfm}

{ TfMain }

procedure TfMain.bAddClick(Sender: TObject);
begin
   //очищаем поля, если там что-то есть:
  fEdit.eReader.Text:= '';
  fEdit.DateHBEdit1.Text:= '  .  .    ';
  fEdit.eBook.Text:= '';
  fEdit.eWriter.Text:= '';
  //устанавливаем ModalResult редактора в mrNone:
  fEdit.ModalResult:= mrNone;
  //теперь выводим форму:
  fEdit.ShowModal;
  //если пользователь ничего не ввел - выходим:
  if (fEdit.eReader.Text= '') or (fEdit.eBook.Text= '') or (fEdit.eWriter.Text= '') then exit;
  //если пользователь не нажал "Сохранить" - выходим:
  if fEdit.ModalResult <> mrOk then exit;
  //иначе добавляем в сетку строку, и заполняем её:
  SG.RowCount:= SG.RowCount + 1;
  SG.Cells[0, SG.RowCount-1]:= fEdit.eReader.Text;
  SG.Cells[1, SG.RowCount-1]:= fEdit.DateHBEdit1.Text;
  SG.Cells[2, SG.RowCount-1]:= fEdit.eBook.Text;
  SG.Cells[3, SG.RowCount-1]:= fEdit.eWriter.Text;
end;

procedure TfMain.bDelClick(Sender: TObject);
begin
   //если данных нет - выходим:
  if SG.RowCount = 1 then exit;
  //иначе выводим запрос на подтверждение:
  if MessageDlg('Требуется подтверждение',
                'Вы действительно хотите удалить контакт "' +
                SG.Cells[0, SG.Row] + '"?',
      mtConfirmation, [mbYes, mbNo, mbIgnore], 0) = mrYes then
         SG.DeleteRow(SG.Row);
end;

procedure TfMain.bEditClick(Sender: TObject);
begin
  //если данных в сетке нет - просто выходим:
  if SG.RowCount = 1 then exit;
  //иначе записываем данные в форму редактора:
  fEdit.eReader.Text:= SG.Cells[0, SG.Row];
  fEdit.DateHBEdit1.Text:= SG.Cells[1, SG.Row];
  fEdit.eBook.Text:= SG.Cells[2, SG.Row];
  fEdit.eWriter.Text:= SG.Cells[3, SG.Row];
  //устанавливаем ModalResult редактора в mrNone:
  fEdit.ModalResult:= mrNone;
  //теперь выводим форму:
  fEdit.ShowModal;
  //сохраняем в сетку возможные изменения,
  //если пользователь нажал "Сохранить":
  if fEdit.ModalResult = mrOk then begin
    SG.Cells[0, SG.Row]:= fEdit.eReader.Text;
    SG.Cells[1, SG.Row]:= fEdit.DateHBEdit1.Text;
    SG.Cells[2, SG.Row]:= fEdit.eBook.Text;
    SG.Cells[3, SG.Row]:= fEdit.eWriter.Text;
  end;
end;

procedure TfMain.bSortClick(Sender: TObject);
begin
   //если данных в сетке нет - просто выходим:
  if SG.RowCount = 1 then exit;
  //иначе сортируем список:
  SG.SortColRow(true, 0)
end;

procedure TfMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  MyCont: Bibl; //для очередной записи
  f: file of Bibl; //файл данных
  i: integer; //счетчик цикла
begin
  //если строки данных пусты, просто выходим:
  if SG.RowCount = 1 then exit;
  //иначе открываем файл для записи:
  try
    AssignFile(f, adres + 'telephones.dat');
    Rewrite(f);
    //запись данных в файл мы организовали в виде цикла; теперь цикл - от первой до последней записи сетки:
    for i:= 1 to SG.RowCount-1 do begin
      //получаем данные текущей записи:
      MyCont.Reader:= SG.Cells[0, i];
      MyCont.Date:= SG.Cells[1, i];
      MyCont.Book:= SG.Cells[2, i];
      MyCont.Writer:= SG.Cells[3, i];
      //записываем их:
      Write(f, MyCont);
    end;
  finally
    CloseFile(f);
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
var
  MyCont: Bibl; //для очередной записи
  f: file of Bibl; //файл данных
  i: integer; //счетчик цикла
begin
  //В параметре ParamStr хранится адрес и имя загружаемой программы
  //Функция ExtractFilePath отсекает имя файла, возвращая только его адрес с завершающим "\"
  //получим адрес программы:
  adres:= ExtractFilePath(ParamStr(0));
  //настроим сетку:
  SG.Cells[0, 0]:= 'Читатель';
  SG.Cells[1, 0]:= 'Дата';
  SG.Cells[2, 0]:= 'Книга';
  SG.Cells[3, 0]:= 'Автор';
  SG.ColWidths[0]:= 250;
  SG.ColWidths[1]:= 150;
  SG.ColWidths[2]:= 250;
  SG.ColWidths[3]:= 250;
  //если файла данных нет, просто выходим:
  if not FileExists(adres + 'telephones.dat') then exit;
  //иначе файл есть, открываем его для чтения и
  //считываем данные в сетку:
  try
    AssignFile(f, adres + 'telephones.dat');
    Reset(f);
    //теперь цикл - от первой до последней записи сетки:
    //делать, пока не конец файла
    while not Eof(f) do begin
      //считываем новую запись:
      Read(f, MyCont);
      //добавляем в сетку новую строку, и заполняем её:
        SG.RowCount:= SG.RowCount + 1;
        SG.Cells[0, SG.RowCount-1]:= MyCont.Reader;
        SG.Cells[1, SG.RowCount-1]:= MyCont.Date;
        SG.Cells[2, SG.RowCount-1]:= MyCont.Book;
        SG.Cells[3, SG.RowCount-1]:= MyCont.Writer;

    end;

  finally
    CloseFile(f);
  end;
end;

end.

