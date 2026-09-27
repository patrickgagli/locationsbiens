unit interface2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  ExtCtrls, SQLDB, DB, db_connection, utils;

type
  TForm2 = class(TForm)
    // Components
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LabelPrixMoyen: TLabel;
    LabelBienId: TLabel;
    ComboCommune: TComboBox;
    BtnRefreshCommunes: TButton;
    BtnShowAll: TButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    GroupBox1: TGroupBox;
    EditAugmentation: TEdit;
    EditDiminution: TEdit;
    BtnAjusterPrix: TButton;
    BtnGetBienDetails: TButton;
    
    // Event handlers
    procedure ComboCommuneChange(Sender: TObject);
    procedure BtnRefreshCommunesClick(Sender: TObject);
    procedure BtnShowAllClick(Sender: TObject);
    procedure DBGrid1CellClick(Column: TColumn);
    procedure BtnAjusterPrixClick(Sender: TObject);
    procedure BtnGetBienDetailsClick(Sender: TObject);
    
  private
    FDBManager: TDatabaseManager;
    FQueryBiens: TSQLQuery;
    FSelectedBienId: Integer;
    procedure ConnectDatabase;
    procedure LoadBiens;
    procedure LoadCommunes;
    procedure UpdateAveragePrice;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

constructor TForm2.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FDBManager := TDatabaseManager.Create;
  FQueryBiens := TSQLQuery.Create(nil);
  FSelectedBienId := -1;
  
  try
    ConnectDatabase;
    LoadCommunes;
    LoadBiens;
    UpdateAveragePrice;
  except
    on E: Exception do
      ShowMessage('Erreur initialisation: ' + E.Message);
  end;
end;

destructor TForm2.Destroy;
begin
  FreeAndNil(FQueryBiens);
  FreeAndNil(FDBManager);
  inherited Destroy;
end;

procedure TForm2.ConnectDatabase;
begin
  try
    FDBManager.Connect;
    if not FDBManager.Transaction.Active then
      FDBManager.Transaction.Active := True;
  except
    on E: Exception do
      raise Exception.CreateFmt('Erreur de connexion: %s', [E.Message]);
  end;
end;

procedure TForm2.LoadBiens;
var
  Commune: string;
begin
  if not FDBManager.Connected then Exit;
  
  try
    FQueryBiens.Close;
    FQueryBiens.Database := FDBManager.Connection;
    FQueryBiens.Transaction := FDBManager.Transaction;
    
    // Check if filtering by commune
    if (ComboCommune.ItemIndex > 0) and (ComboCommune.Text <> '') then
    begin
      Commune := ComboCommune.Text;
      FQueryBiens.SQL.Text := 
        'SELECT id_bien, type_bien, commune, prix, superficie, adresse, id_proprietaire ' +
        'FROM bien WHERE commune = :commune ORDER BY commune, prix';
      FQueryBiens.Params.ParamByName('commune').AsString := Commune;
    end
    else
    begin
      FQueryBiens.SQL.Text := 
        'SELECT id_bien, type_bien, commune, prix, superficie, adresse, id_proprietaire ' +
        'FROM bien ORDER BY commune, prix';
    end;
    
    FQueryBiens.Open;
    DataSource1.DataSet := FQueryBiens;
    
    // Update average price based on current filter
    UpdateAveragePrice;
  except
    on E: Exception do
      ShowMessage('Erreur chargement biens: ' + E.Message);
  end;
end;

procedure TForm2.LoadCommunes;
var
  Query: TSQLQuery;
begin
  if not FDBManager.Connected then Exit;
  
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := FDBManager.Connection;
    Query.Transaction := FDBManager.Transaction;
    Query.SQL.Text := 'SELECT DISTINCT commune FROM bien ORDER BY commune';
    Query.Open;
    
    ComboCommune.Items.Clear;
    ComboCommune.Items.Add('(Tous)');
    
    while not Query.EOF do
    begin
      ComboCommune.Items.Add(Query.FieldByName('commune').AsString);
      Query.Next;
    end;
    
    ComboCommune.ItemIndex := 0;
  finally
    Query.Free;
  end;
end;

procedure TForm2.UpdateAveragePrice;
var
  Query: TSQLQuery;
  AvgPrice: Double;
  Commune: string;
begin
  if not FDBManager.Connected then Exit;
  
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := FDBManager.Connection;
    Query.Transaction := FDBManager.Transaction;
    
    // Calculate average based on current filter
    if (ComboCommune.ItemIndex > 0) and (ComboCommune.Text <> '') then
    begin
      Commune := ComboCommune.Text;
      Query.SQL.Text := 'SELECT AVG(prix) AS prix_moyen FROM bien WHERE commune = :commune';
      Query.Params.ParamByName('commune').AsString := Commune;
    end
    else
    begin
      Query.SQL.Text := 'SELECT AVG(prix) AS prix_moyen FROM bien';
    end;
    
    Query.Open;
    
    if not Query.FieldByName('prix_moyen').IsNull then
    begin
      AvgPrice := Query.FieldByName('prix_moyen').AsFloat;
      LabelPrixMoyen.Caption := FormatMoney(AvgPrice) + ' €';
    end
    else
      LabelPrixMoyen.Caption := 'N/A';
  finally
    Query.Free;
  end;
end;

procedure TForm2.ComboCommuneChange(Sender: TObject);
begin
  try
    LoadBiens;
  except
    on E: Exception do
      ShowMessage('Erreur lors du changement de commune: ' + E.Message);
  end;
end;

procedure TForm2.BtnRefreshCommunesClick(Sender: TObject);
begin
  try
    LoadCommunes;
    LoadBiens;
    ShowMessage('Liste des communes actualisée.');
  except
    on E: Exception do
      ShowMessage('Erreur lors de l''actualisation: ' + E.Message);
  end;
end;

procedure TForm2.BtnShowAllClick(Sender: TObject);
begin
  try
    ComboCommune.ItemIndex := 0;  // Select "(Tous)"
    LoadBiens;
  except
    on E: Exception do
      ShowMessage('Erreur lors de l''affichage: ' + E.Message);
  end;
end;

procedure TForm2.DBGrid1CellClick(Column: TColumn);
begin
  if not FQueryBiens.IsEmpty then
  begin
    FSelectedBienId := FQueryBiens.FieldByName('id_bien').AsInteger;
    LabelBienId.Caption := 'ID: ' + IntToStr(FSelectedBienId);
  end;
end;

procedure TForm2.BtnAjusterPrixClick(Sender: TObject);
var
  Query: TSQLQuery;
  PercentDelta: Double;
  DeltaStr: string;
  NewPrice: Double;
begin
  if FSelectedBienId < 0 then
  begin
    ShowMessage('Veuillez sélectionner un bien dans la grille.');
    Exit;
  end;
  
  // Determine which field to use
  DeltaStr := Trim(EditAugmentation.Text);
  if DeltaStr = '' then
    DeltaStr := Trim(EditDiminution.Text);
    
  if DeltaStr = '' then
  begin
    ShowMessage('Veuillez saisir un pourcentage d''ajustement.');
    Exit;
  end;
  
  // Parse percent (handles comma/point)
  if not TryParsePercent(DeltaStr, PercentDelta) then
  begin
    ShowMessage('Format de pourcentage invalide. Utilisez par exemple: 10 ou 10%');
    Exit;
  end;
  
  // If using diminution field, make it negative
  if Trim(EditDiminution.Text) <> '' then
    PercentDelta := -PercentDelta;
  
  Query := TSQLQuery.Create(nil);
  try
    Query.Database := FDBManager.Connection;
    Query.Transaction := FDBManager.Transaction;
    
    // Call stored procedure
    Query.SQL.Text := 'CALL maj_prix_bien(:p_id_bien, :p_delta)';
    Query.Params.ParamByName('p_id_bien').AsInteger := FSelectedBienId;
    Query.Params.ParamByName('p_delta').AsFloat := PercentDelta * 100;  // Convert back to percent
    
    Query.ExecSQL;
    FDBManager.Transaction.Commit;
    
    // Get updated price
    Query.Close;
    Query.SQL.Text := 'SELECT prix FROM bien WHERE id_bien = :id';
    Query.Params.ParamByName('id').AsInteger := FSelectedBienId;
    Query.Open;
    
    if not Query.EOF then
    begin
      NewPrice := Query.FieldByName('prix').AsFloat;
      ShowMessage(Format('Prix ajusté avec succès. Nouveau prix: %s €', [FormatMoney(NewPrice)]));
    end;
    
    // Clear fields
    EditAugmentation.Text := '';
    EditDiminution.Text := '';
    
    // Refresh data
    LoadBiens;
    UpdateAveragePrice;
  except
    on E: Exception do
    begin
      FDBManager.Transaction.Rollback;
      ShowMessage('Erreur lors de l''ajustement du prix: ' + E.Message);
    end;
  end;
  Query.Free;
end;

procedure TForm2.BtnGetBienDetailsClick(Sender: TObject);
var
  Details: string;
begin
  if FQueryBiens.IsEmpty then
  begin
    ShowMessage('Aucun bien sélectionné.');
    Exit;
  end;
  
  try
    Details := 'Détails du bien:' + LineEnding +
               'ID: ' + FQueryBiens.FieldByName('id_bien').AsString + LineEnding +
               'Type: ' + FQueryBiens.FieldByName('type_bien').AsString + LineEnding +
               'Commune: ' + FQueryBiens.FieldByName('commune').AsString + LineEnding +
               'Prix: ' + FormatMoney(FQueryBiens.FieldByName('prix').AsFloat) + ' €' + LineEnding +
               'Superficie: ' + FQueryBiens.FieldByName('superficie').AsString + ' m²' + LineEnding +
               'Adresse: ' + FQueryBiens.FieldByName('adresse').AsString;
    
    ShowMessage(Details);
  except
    on E: Exception do
      ShowMessage('Erreur lors de la récupération des détails: ' + E.Message);
  end;
end;

end.