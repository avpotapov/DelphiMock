unit SampleMock;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Rtti,
  DUnitX.TestFramework, Delphi.Mocks;

type

{$M+}
  ISample = interface
    ['{69162E72-8C1E-421B-B970-15230BBB3B2B}']
    function GetProp: string;
    procedure SetProp(const Value: string);
    function GetIndexProp(Index: Integer): string;
    procedure SetIndexedProp(Index: Integer; const Value: string);
    function Bar(const Param: Integer): string; overload;
    function Bar(const Param: Integer; const Param2: string): string; overload;
    function ReturnObject: TObject;
    procedure TestMe;
    procedure TestVarParam(var msg: string);
    procedure TestOutParam(out msg: string);
    property MyProp: string read GetProp write SetProp;
    property IndexedProp[index: Integer]: string read GetIndexProp write SetIndexedProp;
  end;
{$M-} // important because otherwise the code below will fail!

  [TestFixture]
  TMyTestObject = class(TObject)
  private
    FMock: TMock<ISample>;
    procedure SetupBar;
    procedure SetupTestMe;
    procedure SetupTestVarParam;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    [TestCase('TestA', '0, Hello')]
    [TestCase('TestB', '1, blah blah')]
    procedure TestBar(const Param: Integer; AExpectedValue: string);

    [Test]
    [TestCase('TestA', '2, sdfsd, goodbye world')]
    [TestCase('TestB', '5, ffgf, helloooooooo')]
    procedure TestBar2(const Param: Integer; const Param2: string; AExpectedValue: string);

    [Test]
    procedure TestMe;

    [Test]
    [TestCase('TestA', 'sdfsd')]
    procedure TestVarParam(var msg : string);
  end;

implementation

procedure TMyTestObject.SetupBar;
begin
  FMock.Setup.WillReturn('blah blah').When.Bar(1);
  FMock.Setup.WillReturnDefault('Bar', 'Hello');
  FMock.Setup.WillReturn('goodbye world').When.Bar(2, 'sdfsd');
  FMock.Setup.WillReturn('helloooooooo').When.Bar(It(0).IsAny<integer>,It(1).IsAny<string>);
end;

procedure TMyTestObject.TestBar(const Param: Integer; AExpectedValue: string);
begin
  Assert.AreEqual<string>(FMock.Instance.Bar(Param), Trim(AExpectedValue));
end;

procedure TMyTestObject.TestBar2(const Param: Integer; const Param2: string; AExpectedValue: string);
begin
  Assert.AreEqual<string>(FMock.Instance.Bar(Param, Trim(Param2)), Trim(AExpectedValue));
end;

procedure TMyTestObject.SetupTestMe;
begin
  FMock.Setup.WillRaise(EMockException, 'You called me when I told you not to!').When.TestMe;
end;

procedure TMyTestObject.TestMe;
begin
  try
    // test a method that we have setup to throw an exception
   FMock.Instance.TestMe;
  except
    on e: Exception do
    begin
      WriteLn('We caught an exception : ' + e.Message);
    end;
  end;
end;

procedure TMyTestObject.SetupTestVarParam;
var
  Msg: string;
begin
  FMock.Setup.WillExecute(
    function (const args : TArray<TValue>; const ReturnType : TRttiType) : TValue
    begin
      args[1] := 'hello Delphi Mocks!';
    end
    ).When.TestVarParam(Msg);
end;


procedure TMyTestObject.TestVarParam(var msg: string);
var
  M: string;
begin
  FMock.Instance.TestVarParam(M);
  Assert.AreEqual<string>(M, 'hello Delphi Mocks!');
end;

procedure TMyTestObject.Setup;
begin
  FMock := TMock<ISample>.Create;
  // Настройки
  SetupBar;
  SetupTestMe;
  SetupTestVarParam;
end;

procedure TMyTestObject.TearDown;
begin
  FMock.Free;
end;

initialization

TDUnitX.RegisterTestFixture(TMyTestObject);

end.
