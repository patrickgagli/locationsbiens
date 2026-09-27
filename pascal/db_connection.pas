unit db_connection;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLDB, odbcconn;

type
  TDatabaseManager = class
  private
    FConnection: TODBCConnection;
    FTransaction: TSQLTransaction;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Configure(const ADriver, ADatabaseName, AUser, APassword: string);
    procedure Connect;
    procedure Disconnect;
    function Connected: Boolean;

    property Connection: TODBCConnection read FConnection;
    property Transaction: TSQLTransaction read FTransaction;
  end;

implementation

{ TDatabaseManager }

constructor TDatabaseManager.Create;
begin
  inherited Create;
  FConnection := TODBCConnection.Create(nil);
  FTransaction := TSQLTransaction.Create(nil);
  FConnection.Transaction := FTransaction;

  // Set default configuration values for MySQL ODBC 9.6.0
  FConnection.Driver := 'MySQL ODBC 9.6.0 Unicode Driver';
  FConnection.DatabaseName := 'MySQL92';  // DSN name
  FConnection.UserName := 'root';
  FConnection.Password := '';
end;

destructor TDatabaseManager.Destroy;
begin
  Disconnect;
  FreeAndNil(FTransaction);
  FreeAndNil(FConnection);
  inherited Destroy;
end;

procedure TDatabaseManager.Configure(const ADriver, ADatabaseName, AUser, APassword: string);
begin
  if Connected then
    raise Exception.Create('Cannot configure while connected.');

  FConnection.Driver := ADriver;
  FConnection.DatabaseName := ADatabaseName;  // DSN name
  FConnection.UserName := AUser;
  FConnection.Password := APassword;
end;

procedure TDatabaseManager.Connect;
begin
  if Connected then Exit;
  try
    FConnection.Open;
    FTransaction.Active := True;
  except
    on E: Exception do
    begin
      Disconnect;
      raise Exception.CreateFmt('Connexion MySQL échouée : %s', [E.Message]);
    end;
  end;
end;

procedure TDatabaseManager.Disconnect;
begin
  if FTransaction.Active then
    FTransaction.Active := False;
  if FConnection.Connected then
    FConnection.Close;
end;

function TDatabaseManager.Connected: Boolean;
begin
  Result := Assigned(FConnection) and FConnection.Connected;
end;

end.