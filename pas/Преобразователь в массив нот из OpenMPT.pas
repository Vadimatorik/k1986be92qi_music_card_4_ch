Program Pr;
var input: text;                                                                //Отсюда читаем. 
    BufNOT: byte;                                                               //Номер ноты.
    MESNOT: array [0..3, 0..1000, 0..1] of integer;                             //Массив до 10000 нот в каждом канале.
    BIGSTRING: string;                                                          //Здесь строка на 4 канала.
    Chene_ST:  string;                                                          //Строка для одного канала.
    LoopNOTE_Chenel: array [0..3] of integer;                                   //Номер ноты в каждом канале.
    LoopDELAY_Chenel: array [0..3] of integer;                                  //Ожидание в каждом канале.
    LoopChenel: integer;                                                        //Счетчик каналов.
    I: integer; 
    FLAG_ONE_NOTE: array [0..3] of byte;                                        //Флаг показывает, что хотя бы одна ноты да в канале была. Иначе "пауза" до 1-й ноты.
//Функция принемает строку - выдает номер ноты. 
function PR_String_to_NambeNote (DataST: string): integer;
var Buffer: integer;
    MNOG:   integer;
    errorS: integer; 
Begin
  case DataST[2] of                                                             //По букве и наличию # присваиваем номер ноте в пределах одной октвы. 
  'C': if (DataST[3]='-') then Buffer:=0 else Buffer:=1;
  'D': if (DataST[3]='-') then Buffer:=2 else Buffer:=3;
  'E': Buffer:=4;
  'F': if (DataST[3]='-') then Buffer:=5 else Buffer:=6;
  'G': if (DataST[3]='-') then Buffer:=7 else Buffer:=8;
  'A': if (DataST[3]='-') then Buffer:=9 else Buffer:=10;
  'B': Buffer:=11;
  '=': Buffer:=132; End;
  if (Buffer<>132) then
  Begin
    val(DataST[4], MNOG, errorS);                                               //Получаем номер строки.
    Buffer:=Buffer+12*MNOG;                                                     //Получаем номер ноты на нужно октаве.
  End;
  PR_String_to_NambeNote:=Buffer;                                               //Выдаем номер/паузу
End;

Begin
  assign(input, 'INPUT.txt'); reset(input);                                     //Подключаем файл для чтения.
  while not eof(input) do                                                       //Читаем все строки.
  Begin 
    readln(input, BIGSTRING);                                                   //Читам строку для 4-х каналов. 
    if (BIGSTRING[1] = '|') then                                                //Если это именно наша строка, то.
    Begin
      for LoopChenel:=0 to 3 do                                                 //Проходим все 4 канала.
      Begin
        Chene_ST:=copy(BIGSTRING, 1+12*LoopChenel, 4);                          //Копируем из общей строки нужный канал.    
        if (Chene_ST[2]<>'.') then                                              //Если перед нами нота, то.
        Begin          
          if (FLAG_ONE_NOTE[LoopChenel]=0) then                                 //Если до этой ноты не было ни одной, то сделать до нее паузу.
          Begin
            if (LoopDELAY_Chenel[LoopChenel]<>0) then
            Begin
              MESNOT[LoopChenel][0][0]:=132;                                    //Передвигаем указатель в "0".
              MESNOT[LoopChenel][0][1]:=LoopDELAY_Chenel[LoopChenel];           //Указываем длительность паузы.
              LoopNOTE_Chenel[LoopChenel]:=LoopNOTE_Chenel[LoopChenel]+1;       //Передвигаем указатель на следущую ноту.
            End;
            FLAG_ONE_NOTE[LoopChenel]:=1;
          End;
          MESNOT[LoopChenel][LoopNOTE_Chenel[LoopChenel]][0]:=PR_String_to_NambeNote(Chene_ST);   //Получаем номер ноты. 
          if (LoopNOTE_Chenel[LoopChenel]<>0) then
           MESNOT[LoopChenel][LoopNOTE_Chenel[LoopChenel]-1][1]:=LoopDELAY_Chenel[LoopChenel];    //Указываем длительность предыдущей (если она была).
          LoopNOTE_Chenel[LoopChenel]:=LoopNOTE_Chenel[LoopChenel]+1;                             //Передвигаем указатель на следущую ноту.
          LoopDELAY_Chenel[LoopChenel]:=1;                                                        //По умолчанию длинна ноты 1/128.     
        End
        else LoopDELAY_Chenel[LoopChenel]:=LoopDELAY_Chenel[LoopChenel]+1;      //Если сейчас пауза - просто ждем.
      End;
    End;
  End;
  
  MESNOT[0][LoopNOTE_Chenel[0]-1][1]:=LoopDELAY_Chenel[0];                      //Присваиваем последней ноте ее задержку.  
  MESNOT[1][LoopNOTE_Chenel[1]-1][1]:=LoopDELAY_Chenel[1];                      //Присваиваем последней ноте ее задержку.  
  MESNOT[2][LoopNOTE_Chenel[2]-1][1]:=LoopDELAY_Chenel[2];                      //Присваиваем последней ноте ее задержку.  
  MESNOT[3][LoopNOTE_Chenel[3]-1][1]:=LoopDELAY_Chenel[3];                      //Присваиваем последней ноте ее задержку.  
  
  for LoopChenel:=0 to 3 do
  Begin
    write('uint16_t MusicNote', LoopChenel, '[', LoopNOTE_Chenel[LoopChenel], '][2] = {');
    for I:=0 to LoopNOTE_Chenel[LoopChenel]-1 do 
    Begin
      write (MESNOT[LoopChenel][I][0],  ',', MESNOT[LoopChenel][I][1]);  
      if (I<>LoopNOTE_Chenel[LoopChenel]-1) then write(', ');
    End;
    writeln('};');
  End;
End.