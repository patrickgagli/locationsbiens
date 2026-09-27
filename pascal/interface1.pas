unit interface1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  DBGrids, ExtCtrls, SQLDB, DB, db_connection, utils;

type
  TForm1 = class(TForm)
    // Tab Control
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    
    // Onglet 1 - Gestion Propriétaires
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EditNom: TEdit;
    EditDomicile: TEdit;
    EditTelephone: TEdit;
    EditEmail: TEdit;
    BtnAddProprietaire: TButton;
    BtnDeleteProprietaire: TButton;
    BtnRefresh: TButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    
    // Onglet 2 - Recherche Biens
    Panel2: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    EditSearchNom: TEdit;
    EditSearchDomicile: TEdit;
    EditSearchCommune: TEdit;
    EditPrixMin: TEdit;
    EditPrixMax: TEdit;
    EditSuperficieMin: TEdit;
    EditSuperficieMax: TEdit;
    CheckPrixMin: TCheckBox;
    CheckPrixMax: TCheckBox;
    CheckSuperficieMin: TCheckBox;
    CheckSuperficieMax: TCheckBox;
    BtnSearch: TButton;
    DBGrid2: TDBGrid;
    DataSource2: TDataSource;
    
    // Event handlers
    procedure BtnAddProprietaireClick(Sender: TObject);
    procedure BtnDeleteProprietaireClick(Sender: TObject);
    procedure BtnRefreshClick(Sender: TObject);
    procedure BtnSearchClick(Sender: TObject);
    
  private
    FDBManager: TDatabaseManager;
    FQueryProprietaires: TSQLQuery;
    FQuerySearch: TSQLQuery;
    procedure ConnectDatabase;
    procedure LoadProprietaires;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

constructor TForm1.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FDBManager := TDatabaseManager.Create;
  FQueryProprietaires := TSQLQuery.Create(nil);
  FQuerySearch := TSQLQuery.Create(nil);
  
  try
    ConnectDatabase;
    LoadProprietaires;
  except
    on E: Exception do
      ShowMessage('Erreur initialisation: ' + E.Message);
  end;
end;

destructor TForm1.Destroy;
begin
  FreeAndNil(FQuerySearch);
  FreeAndNil(FQueryProprietaires);
  FreeAndNil(FDBManager);
  inherited Destroy;
end;

procedure TForm1.ConnectDatabase;
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

procedure TForm1.LoadProprietaires;
begin
  if not FDBManager.Connected then Exit;
  
  try
    FQueryProprietaires.Close;
    FQueryProprietaires.Database := FDBManager.Connection;
    FQueryProprietaires.Transaction := FDBManager.Transaction;
    FQueryProprietaires.SQL.Text := 
      'SELECT id_proprietaire, nom, domicile, telephone, email FROM proprietaire ORDER BY nom';
    FQueryProprietaires.Open;
    
    DataSource1.DataSet := FQueryProprietaires;
  except
    on E: Exception do
      ShowMessage('Erreur chargement propriétaires: ' + E.Message);
  end;
end;

procedure TForm1.BtnAddProprietaireClick(Sender: TObject);
var
  InsertQuery: TSQLQuery;
  Nom, Domicile, Telephone, Email: string;
begin
  Nom := Trim(EditNom.Text);
  Domicile := Trim(EditDomicile.Text);
  Telephone := Trim(EditTelephone.Text);
  Email := Trim(EditEmail.Text);
  
  // Validation
  if Nom = '' then
  begin
    ShowMessage('Le nom est obligatoire.');
    EditNom.SetFocus;
    Exit;
  end;
  
  if Domicile = '' then
  begin
    ShowMessage('Le domicile est obligatoire.');
    EditDomicile.SetFocus;
    Exit;
  end;
  
  InsertQuery := TSQLQuery.Create(nil);
  try
    InsertQuery.Database := FDBManager.Connection;
    InsertQuery.Transaction := FDBManager.Transaction;
    InsertQuery.SQL.Text := 
      'INSERT INTO proprietaire (nom, domicile, telephone, email) ' +
      'VALUES (:nom, :domicile, :telephone, :email)';
    
    InsertQuery.Params.ParamByName('nom').AsString := Nom;
    InsertQuery.Params.ParamByName('domicile').AsString := Domicile;
    
    if Telephone <> '' then
      InsertQuery.Params.ParamByName('telephone').AsString := Telephone
    else
      InsertQuery.Params.ParamByName('telephone').Clear;
      
    if Email <> '' then
      InsertQuery.Params.ParamByName('email').AsString := Email
    else
      InsertQuery.Params.ParamByName('email').Clear;
    
    try
      InsertQuery.ExecSQL;
      FDBManager.Transaction.Commit;
      
      // Clear fields
      EditNom.Text := '';
      EditDomicile.Text := '';
      EditTelephone.Text := '';
      EditEmail.Text := '';
      
      LoadProprietaires;
      ShowMessage('Propriétaire ajouté avec succès.');
    except
      on E: Exception do
      begin
        FDBManager.Transaction.Rollback;
        ShowMessage('Erreur lors de l''ajout: ' + E.Message);
      end;
    end;
  finally
    InsertQuery.Free;
  end;
end;

procedure TForm1.BtnDeleteProprietaireClick(Sender: TObject);
var
  DeleteQuery: TSQLQuery;
  ProprietaireId: Integer;
  Nom: string;
begin
  if FQueryProprietaires.IsEmpty then
  begin
    ShowMessage('Aucun propriétaire sélectionné.');
    Exit;
  end;
  
  ProprietaireId := FQueryProprietaires.FieldByName('id_proprietaire').AsInteger;
  Nom := FQueryProprietaires.FieldByName('nom').AsString;
  
  if MessageDlg('Confirmation',
    Format('Supprimer le propriétaire "%s" ? Cette action supprimera également tous ses biens et locations (cascade).', [Nom]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  
  DeleteQuery := TSQLQuery.Create(nil);
  try
    DeleteQuery.Database := FDBManager.Connection;
    DeleteQuery.Transaction := FDBManager.Transaction;
    DeleteQuery.SQL.Text := 'DELETE FROM proprietaire WHERE id_proprietaire = :id';
    DeleteQuery.Params.ParamByName('id').AsInteger := ProprietaireId;
    
    try
      DeleteQuery.ExecSQL;
      FDBManager.Transaction.Commit;
      LoadProprietaires;
      ShowMessage('Propriétaire supprimé avec succès.');
    except
      on E: Exception do
      begin
        FDBManager.Transaction.Rollback;
        ShowMessage('Erreur lors de la suppression: ' + E.Message);
      end;
    end;
  finally
    DeleteQuery.Free;
  end;
end;

procedure TForm1.BtnRefreshClick(Sender: TObject);
begin
  try
    LoadProprietaires;
    ShowMessage('Liste actualisée.');
  except
    on E: Exception do
      ShowMessage('Erreur lors de l''actualisation: ' + E.Message);
  end;
end;

procedure TForm1.BtnSearchClick(Sender: TObject);
var
  SQL: string;
  NomProp, DomicileProp, Commune: string;
  PrixMin, PrixMax, SuperficieMin, SuperficieMax: Double;
  HasWhere: Boolean;
begin
  if not FDBManager.Connected then Exit;
  
  // Build dynamic query
  SQL := 'SELECT DISTINCT p.nom AS proprietaire_nom, p.domicile AS proprietaire_domicile, ' +
         'b.id_bien, b.type_bien, b.commune, b.prix, b.superficie, b.adresse ' +
         'FROM proprietaire p ' +
         'LEFT JOIN bien b ON p.id_proprietaire = b.id_proprietaire ' +
         'WHERE 1=1 ';
  
  HasWhere := True;
  
  try
    FQuerySearch.Close;
    FQuerySearch.Database := FDBManager.Connection;
    FQuerySearch.Transaction := FDBManager.Transaction;
    
    // Proprietaire filters
    NomProp := Trim(EditSearchNom.Text);
    if NomProp <> '' then
    begin
      SQL := SQL + 'AND p.nom LIKE :nom_prop ';
    end;
    
    DomicileProp := Trim(EditSearchDomicile.Text);
    if DomicileProp <> '' then
    begin
      SQL := SQL + 'AND p.domicile LIKE :domicile_prop ';
    end;
    
    // Bien filters
    Commune := Trim(EditSearchCommune.Text);
    if Commune <> '' then
    begin
      SQL := SQL + 'AND b.commune LIKE :commune ';
    end;
    
    if CheckPrixMin.Checked and (Trim(EditPrixMin.Text) <> '') then
    begin
      SQL := SQL + 'AND b.prix >= :prix_min ';
    end;
    
    if CheckPrixMax.Checked and (Trim(EditPrixMax.Text) <> '') then
    begin
      SQL := SQL + 'AND b.prix <= :prix_max ';
    end;
    
    if CheckSuperficieMin.Checked and (Trim(EditSuperficieMin.Text) <> '') then
    begin
      SQL := SQL + 'AND b.superficie >= :superficie_min ';
    end;
    
    if CheckSuperficieMax.Checked and (Trim(EditSuperficieMax.Text) <> '') then
    begin
      SQL := SQL + 'AND b.superficie <= :superficie_max ';
    end;
    
    SQL := SQL + 'ORDER BY p.nom, b.commune';
    
    FQuerySearch.SQL.Text := SQL;
    
    // Set parameters
    if NomProp <> '' then
      FQuerySearch.Params.ParamByName('nom_prop').AsString := NormalizeLikeParam(NomProp);
      
    if DomicileProp <> '' then
      FQuerySearch.Params.ParamByName('domicile_prop').AsString := NormalizeLikeParam(DomicileProp);
      
    if Commune <> '' then
      FQuerySearch.Params.ParamByName('commune').AsString := NormalizeLikeParam(Commune);
    
    if CheckPrixMin.Checked and (Trim(EditPrixMin.Text) <> '') then
    begin
      if TryStrToFloat(StringReplace(Trim(EditPrixMin.Text), ',', '.', [rfReplaceAll]), PrixMin) then
        FQuerySearch.Params.ParamByName('prix_min').AsFloat := PrixMin
      else
      begin
        ShowMessage('Prix minimum invalide.');
        Exit;
      end;
    end;
    
    if CheckPrixMax.Checked and (Trim(EditPrixMax.Text) <> '') then
    begin
      if TryStrToFloat(StringReplace(Trim(EditPrixMax.Text), ',', '.', [rfReplaceAll]), PrixMax) then
        FQuerySearch.Params.ParamByName('prix_max').AsFloat := PrixMax
      else
      begin
        ShowMessage('Prix maximum invalide.');
        Exit;
      end;
    end;
    
    if CheckSuperficieMin.Checked and (Trim(EditSuperficieMin.Text) <> '') then
    begin
      if TryStrToFloat(StringReplace(Trim(EditSuperficieMin.Text), ',', '.', [rfReplaceAll]), SuperficieMin) then
        FQuerySearch.Params.ParamByName('superficie_min').AsFloat := SuperficieMin
      else
      begin
        ShowMessage('Superficie minimum invalide.');
        Exit;
      end;
    end;
    
    if CheckSuperficieMax.Checked and (Trim(EditSuperficieMax.Text) <> '') then
    begin
      if TryStrToFloat(StringReplace(Trim(EditSuperficieMax.Text), ',', '.', [rfReplaceAll]), SuperficieMax) then
        FQuerySearch.Params.ParamByName('superficie_max').AsFloat := SuperficieMax
      else
      begin
        ShowMessage('Superficie maximum invalide.');
        Exit;
      end;
    end;
    
    FQuerySearch.Open;
    DataSource2.DataSet := FQuerySearch;
    
    ShowMessage(Format('Recherche terminée: %d résultat(s) trouvé(s).', [FQuerySearch.RecordCount]));
  except
    on E: Exception do
      ShowMessage('Erreur lors de la recherche: ' + E.Message);
  end;
end;

end.