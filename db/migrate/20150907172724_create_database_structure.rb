class CreateDatabaseStructure < ActiveRecord::Migration
  def change
    unless ActiveRecord::Base.connection.table_exists? 'Adressenpool'
      create_table "Adressenpool", primary_key: "AdressenpoolID", force: true do |t|
        t.integer "LoginID",                                null: false
        t.string  "Land",        limit: 25,                 null: false
        t.string  "Ort",         limit: 25,                 null: false
        t.string  "PLZ",         limit: 10,                 null: false
        t.string  "Adresse",     limit: 40,                 null: false
        t.string  "Kurzadresse", limit: 20,                 null: false
        t.boolean "deaktiviert",            default: false, null: false
      end

      create_table "ArbeitsAuftrag", primary_key: "ArbeitstAuftragID", force: true do |t|
        t.string   "TaetigkeitsType",         limit: 1,                            default: "A"
        t.decimal  "KundenauftragID",                     precision: 18, scale: 0
        t.decimal  "KostenstelleID",                      precision: 18, scale: 0,                 null: false
        t.decimal  "ArbeitsKosten"
        t.string   "ArbeitsBemerkung",        limit: 250,                                          null: false
        t.string   "SekKontrollBemerkungen",  limit: 250
        t.boolean  "SekKontroll",                                                  default: false, null: false
        t.boolean  "BuchngsKontroll",                                              default: false, null: false
        t.boolean  "AuftragsStorno",                                               default: false, null: false
        t.datetime "AuftragsSTornoTimestemp"
        t.datetime "Druckdatum"
        t.decimal  "FahrerID1",                           precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID2",                           precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID3",                           precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID4",                           precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID5",                           precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID6",                           precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID7",                           precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID8",                           precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID9",                           precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID10",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID11",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID12",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID13",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID14",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID15",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID16",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID17",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID18",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID19",                          precision: 18, scale: 0, default: 0
        t.decimal  "FahrerID20",                          precision: 18, scale: 0, default: 0
        t.float    "ArbeitsZeit",             limit: 53,                           default: 0.0
        t.datetime "RechnungslegungEXT"
        t.datetime "Buchungsdatum"
        t.datetime "Druckdatum_orginal"
        t.integer  "Anzahl_Kopien",                                                default: 0
        t.datetime "BuchungsFreigabe"
        t.boolean  "Freigegeben",                                                                  null: false
        t.integer  "Status",                                                       default: 0,     null: false
        t.datetime "AuftragDatum",                                                                 null: false
        t.string   "TelNr",                   limit: 3
      end

      create_table "Betriebsmittel", primary_key: "ID", force: true do |t|
        t.string  "Typ",                limit: 50, null: false
        t.string  "Währung",            limit: 5,  null: false
        t.decimal "Betrag",                        null: false
        t.string  "Bemerkungen"
        t.integer "FrFahrtauftragID"
        t.integer "FrShuttleAuftragID"
        t.integer "TankkartenNummer"
        t.boolean "Bar"
      end

      create_table "FahrerAbrechnung", primary_key: "FahrerAbrechnung", force: true do |t|
        t.string  "TaetigkeitsType",  limit: 1
        t.decimal "KundenaufrtagID",            precision: 18, scale: 0
        t.decimal "BuchungsZeilenID",           precision: 18, scale: 0
        t.decimal "Betrag"
      end

      create_table "FahrerJounal", primary_key: "FahrerJournalID", force: true do |t|
        t.decimal  "FahrerID",                        precision: 18, scale: 0,                 null: false
        t.decimal  "FahrerJournalLaufnummer",         precision: 18, scale: 0
        t.datetime "JournalAusdruck"
        t.datetime "JournalAusdruckstorno"
        t.boolean  "JournalStorno",                                            default: false
        t.decimal  "FahrerJournalLaufnummer_History", precision: 18, scale: 0, default: 0
      end

      create_table "Fahrtauftrag", primary_key: "FahrtAuftragID", force: true do |t|
        t.string   "TaetigkeitsType",                 limit: 1,                            default: "F"
        t.decimal  "KundenauftragID",                             precision: 18, scale: 0
        t.decimal  "KostenstelleID",                              precision: 18, scale: 0
        t.string   "AutoMarke",                       limit: 15
        t.string   "AutoType",                        limit: 15
        t.string   "Kennzeichen",                     limit: 15
        t.string   "FgNr",                            limit: 30
        t.decimal  "UeberstellungVon",                            precision: 18, scale: 0
        t.decimal  "UeberstellungNach",                           precision: 18, scale: 0
        t.string   "AuftragsBemerkungen",             limit: 500
        t.decimal  "FahrerID",                                    precision: 18, scale: 0
        t.decimal  "AbrechnungsModusID",                          precision: 18, scale: 0
        t.decimal  "ArbeitzeitKostenExt"
        t.decimal  "ArbeitzeitKostenInt"
        t.decimal  "TransportKostExt"
        t.string   "TransportKostInt",                limit: 10
        t.decimal  "UebertellungsbetragExt"
        t.decimal  "UebertellungsbetragInt"
        t.string   "TransportBemerkungen",            limit: 500
        t.datetime "GeplantesTransportDatumAbholung"
        t.datetime "RealesAbholDatum"
        t.datetime "GeplanteTransportDatumAbgabe"
        t.datetime "RealesAbgabeDatum"
        t.boolean  "AutobVinjette"
        t.boolean  "BereifungMS"
        t.string   "FzgStatus",                       limit: 20
        t.decimal  "TachostandSoll",                              precision: 18, scale: 0
        t.decimal  "TachostandKMRealAbholung",                    precision: 18, scale: 0
        t.decimal  "TachostandKMRealAbgabe",                      precision: 18, scale: 0
        t.decimal  "TransportKM",                                 precision: 18, scale: 0
        t.boolean  "SekKonrtoll",                                                          default: false
        t.boolean  "BuchungsKotroll",                                                      default: false
        t.datetime "FahrerAuszahlung"
        t.datetime "RechnungslegungEXT"
        t.datetime "RechnungslegungINT"
        t.boolean  "AuftragsStorno",                                                       default: false
        t.datetime "AuftragsSTornoTimestemp"
        t.boolean  "FakturaFreigabe",                                                      default: false
        t.boolean  "InnenReinigung"
        t.datetime "Druckdatum"
        t.boolean  "Ueber3500KG",                                                          default: false
        t.boolean  "NWAufbereitung",                                                       default: false
        t.decimal  "BFahrerID1",                                  precision: 18, scale: 0, default: 0
        t.decimal  "BFahrerID2",                                  precision: 18, scale: 0, default: 0
        t.decimal  "BFahrerID3",                                  precision: 18, scale: 0, default: 0
        t.decimal  "BFahrerID4",                                  precision: 18, scale: 0, default: 0
        t.decimal  "BFahrerID5",                                  precision: 18, scale: 0, default: 0
        t.decimal  "BFahrerID6",                                  precision: 18, scale: 0, default: 0
        t.decimal  "BFahrerID7",                                  precision: 18, scale: 0, default: 0
        t.decimal  "BFahrerID8",                                  precision: 18, scale: 0, default: 0
        t.decimal  "Stehzeit",                                    precision: 19, scale: 2, default: 0.0
        t.decimal  "Treibstoff",                                                           default: 0.0
        t.decimal  "Betriebsmittel",                                                       default: 0.0
        t.decimal  "Maut",                                                                 default: 0.0
        t.integer  "Tankkartennummer",                                                     default: 0
        t.boolean  "Shuttelfahrt",                                                         default: false
        t.string   "SekKontrolleMemo",                limit: 200
        t.datetime "Druckdatum_Orginal"
        t.integer  "Anzahl_Ausdrücke",                                                     default: 0
        t.string   "KnotenpunktVon",                  limit: 40
        t.string   "KnotenpunktNach",                 limit: 40
        t.datetime "BuchungsFreigabe"
        t.string   "TransportBemerkungenExtern",      limit: 500
        t.boolean  "Freigegeben",                                                          default: false
        t.integer  "Status",                                                               default: 0
        t.string   "ShuttleKennzeichen",              limit: 15
        t.string   "TelNr",                           limit: 3,                            default: "0"
        t.boolean  "Merge",                                                                default: false
        t.boolean  "Ersatzauftrag",                                                        default: false
        t.datetime "InsertDate"
        t.string   "MVN",                             limit: 15
        t.boolean  "IsDuplicate"
      end

      create_table "Kundenauftrag", primary_key: "KundenauftragID", force: true do |t|
        t.decimal  "LaufnummerJeKostenstelle",            precision: 18, scale: 0
        t.decimal  "KostenstelleID",                      precision: 18, scale: 0,                 null: false
        t.datetime "Auftragseröffnung",                                                            null: false
        t.boolean  "AuftragAbschluss",                                             default: false
        t.datetime "AufAbTimestemp"
        t.string   "AuftragsNummerExtern",     limit: 20
      end

      create_table "Login_Archive_LOGFILE", primary_key: "LoginTurnID", force: true do |t|
        t.integer  "LoginReturn"
        t.decimal  "LoginID",                               precision: 18, scale: 0
        t.decimal  "FirmaID",                               precision: 10, scale: 0
        t.string   "Login",                      limit: 10
        t.string   "Passwort",                   limit: 10
        t.string   "Vorname",                    limit: 20
        t.string   "Nachname",                   limit: 20
        t.string   "TelNR",                      limit: 20
        t.string   "FaxNR",                      limit: 20
        t.string   "EMail",                      limit: 30
        t.decimal  "BerchtigungID",                         precision: 18, scale: 0
        t.decimal  "UserGruppeID",                          precision: 18, scale: 0
        t.decimal  "KostenstelleID_Berecht",                precision: 18, scale: 0
        t.decimal  "KostenstelleID",                        precision: 18, scale: 0
        t.integer  "MinVorlaufzeitFahrtAuftrag"
        t.integer  "MinVorlaufzeitStorno"
        t.string   "Aktion",                     limit: 10
        t.datetime "Zeitstempel"
      end

      create_table "MailImport_Log", primary_key: "MIL_Id", force: true do |t|
        t.string   "Betreff",        limit: 256
        t.text     "Body"
        t.datetime "AuftragsDatum"
        t.integer  "AuftragsNummer"
        t.text     "Bemerkung"
        t.datetime "timestamp",                  null: false
      end

      create_table "MailImport_Queue", primary_key: "MIQ_Id", force: true do |t|
        t.string   "Betreff",        limit: 256
        t.text     "Body"
        t.datetime "AuftragsDatum"
        t.integer  "AuftragsNummer"
        t.datetime "timestamp",                  null: false
      end

      create_table "MailImport_Settings", id: false, force: true do |t|
        t.boolean "isStarted", default: false, null: false
      end

      create_table "Schaden", primary_key: "SchadenId", force: true do |t|
        t.integer  "SchadenStatusId",           null: false
        t.text     "Kennzeichen"
        t.datetime "SchadenDatum"
        t.text     "SixtSchadenNummer"
        t.text     "VersicherungSchadenNummer"
        t.text     "Notizen"
        t.datetime "CreateDateTime",            null: false
      end

      create_table "SchadenFiles", primary_key: "SchadenFileId", force: true do |t|
        t.integer "SchadenId", null: false
        t.text    "FileName",  null: false
      end

      create_table "SchadenStatus", primary_key: "SchadenStatusId", force: true do |t|
        t.text "Bezeichnung"
      end

      create_table "ShuttelAuftrag", primary_key: "ShuttelAuftragID", force: true do |t|
        t.decimal  "KostenstelleID",                       precision: 18, scale: 0, default: 0
        t.decimal  "KundenauftragID",                      precision: 18, scale: 0
        t.decimal  "FahrtauftragID",                       precision: 18, scale: 0, default: 0
        t.datetime "AbFahrtdatum"
        t.datetime "Ankunftdatum"
        t.integer  "VonId"
        t.string   "Von",                      limit: 40
        t.integer  "NachId"
        t.string   "Nach",                     limit: 40
        t.decimal  "RealKM",                               precision: 18, scale: 0, default: 0
        t.string   "Bemerkung",                limit: 250
        t.string   "Abrechnungsmodus",         limit: 10
        t.string   "Kennzeichen",              limit: 10
        t.decimal  "Treibstoff",                                                    default: 0.0
        t.decimal  "Betriebsmittel",                                                default: 0.0
        t.decimal  "Maut",                                                          default: 0.0
        t.integer  "Tankkartennummer",                                              default: 0
        t.decimal  "FahrerID",                             precision: 18, scale: 0, default: 0
        t.decimal  "BeiFahrer1",                           precision: 18, scale: 0, default: 0
        t.decimal  "BeiFahrer2",                           precision: 18, scale: 0, default: 0
        t.decimal  "BeiFahrer3",                           precision: 18, scale: 0, default: 0
        t.decimal  "BeiFahrer4",                           precision: 18, scale: 0, default: 0
        t.decimal  "BeiFahrer5",                           precision: 18, scale: 0, default: 0
        t.decimal  "BeiFahrer6",                           precision: 18, scale: 0, default: 0
        t.decimal  "BeiFahrer7",                           precision: 18, scale: 0, default: 0
        t.decimal  "BeiFahrer8",                           precision: 18, scale: 0, default: 0
        t.boolean  "BuchungsKontroll",                                              default: false
        t.boolean  "Storno",                                                        default: false
        t.decimal  "ShuttelFahrtKostenIntern"
        t.decimal  "ShuttelFahrtKostenExtern"
        t.datetime "RechnungslegungEXT"
        t.datetime "Buchungsdatum"
        t.float    "Arbeitszeit",              limit: 53,                           default: 0.0
        t.string   "KennzeichenAuftrag",       limit: 25
        t.string   "TelNr",                    limit: 3
        t.boolean  "NichtZugewiesen"
        t.boolean  "IsDuplicate"
      end

      create_table "ShuttelFahrerEntlohnung", primary_key: "ShuttelFahrerEntlohnung", force: true do |t|
        t.decimal  "ShuttelAuftragID",                   precision: 18, scale: 0
        t.decimal  "FahrtAuftragID",                     precision: 18, scale: 0
        t.decimal  "ArbeitsauftragID",                   precision: 18, scale: 0
        t.decimal  "FahrerID",                           precision: 18, scale: 0,             null: false
        t.boolean  "NWAufbereitung"
        t.decimal  "Entlohnung"
        t.datetime "BuchungsfreigabeDatum"
        t.datetime "FahrerAuszahlungDatum"
        t.decimal  "FahrerJournalLaufnummer",            precision: 18, scale: 0, default: 0
        t.string   "Kurzadresse_VON_SH",      limit: 40
        t.string   "Kurzadresse_NACH_SH",     limit: 40
        t.integer  "VonId"
        t.integer  "NachId"
      end

      create_table "ShuttelFahrtDetails", primary_key: "ShuttelAuftragDetailID", force: true do |t|
        t.decimal "ShuttelAuftragID", precision: 18, scale: 0
        t.decimal "FahrtAuftragID",   precision: 18, scale: 0
        t.boolean "Storno",                                    default: false
      end

      create_table "StAbrechnunsModus", primary_key: "AbrechnungsModusID", force: true do |t|
        t.string  "AbrechnungsModus",       limit: 10
        t.integer "AbrechnungsModusNummer"
      end

      create_table "StBerechtigung", primary_key: "BerechtigungID", force: true do |t|
        t.string "BerechtigungsBeschreibung", limit: 25
      end

      create_table "StFahrer", primary_key: "FahrerID", force: true do |t|
        t.string   "Vorname",               limit: 20,                null: false
        t.string   "Nachname",              limit: 20,                null: false
        t.datetime "GebDatum",                                        null: false
        t.string   "GebOrt",                limit: 150,               null: false
        t.string   "Adresse",               limit: 25,                null: false
        t.string   "Ort",                   limit: 25,                null: false
        t.string   "PLZ",                   limit: 10,                null: false
        t.string   "TelNR1",                limit: 30,                null: false
        t.string   "TelNr2",                limit: 30
        t.string   "FS_Nummer",             limit: 10,                null: false
        t.string   "FS_Ausstellungsb",      limit: 20,                null: false
        t.string   "FS_Klassen",            limit: 15,                null: false
        t.datetime "Eintritt",                                        null: false
        t.datetime "Austritt"
        t.string   "Bemerkungen",           limit: 50
        t.string   "SVNummer",              limit: 10,                null: false
        t.boolean  "FSKopie"
        t.boolean  "MeldzettelKopie"
        t.boolean  "Werkvertrag"
        t.decimal  "KostenPerRealKM",                                 null: false
        t.decimal  "Fahrkostenpauschale",                             null: false
        t.decimal  "AbzugFahrer"
        t.string   "AbzugBemerkung",        limit: 500
        t.string   "UID",                   limit: 15
        t.string   "Steuernummer",          limit: 20
        t.decimal  "StundenLohnAA",                     default: 0.0, null: false
        t.decimal  "PauschalLohnNWAuf",                 default: 0.0, null: false
        t.decimal  "KostenPerRealKM35"
        t.decimal  "Fahrkostenpauschale35"
      end

      create_table "StFirma", primary_key: "FirmaID", force: true do |t|
        t.string  "Firma",                      limit: 30,              null: false
        t.string  "Adresse",                    limit: 30,              null: false
        t.string  "Ort",                        limit: 25
        t.string  "PLZ",                        limit: 10,              null: false
        t.string  "Land",                       limit: 30,              null: false
        t.string  "TelNR",                      limit: 20
        t.string  "FaxNR",                      limit: 20
        t.string  "EMail",                      limit: 40
        t.decimal "KostenPerRealKM"
        t.decimal "Fahrkostenpauschale"
        t.decimal "StundensatzArbeitsauftrag"
        t.decimal "PauschaleNWAufbereitung"
        t.integer "MinVorlaufzeitFahrtAuftrag",            default: 24
        t.integer "MinVorlaufzeitStorno"
        t.decimal "KostenPerRealKM35"
        t.decimal "Fahrkostenpauschale35"
        t.decimal "RealKMShuttelfahrt"
        t.decimal "ShuttelPauschale"
        t.integer "AbrechnungsModi"
      end

      create_table "StKMTabelle", primary_key: "KMTabelleID", force: true do |t|
        t.string  "VonAdresse",  limit: 40,                 null: false
        t.string  "NachAdresse", limit: 40,                 null: false
        t.integer "KM",                                     null: false
        t.boolean "Pauschale",              default: false, null: false
      end

      create_table "StKMTabelleNeu", primary_key: "ID", force: true do |t|
        t.integer  "VonID",                default: 0, null: false
        t.integer  "NachID",               default: 0, null: false
        t.integer  "FaStatus",   limit: 1, default: 0
        t.integer  "SHStatus",   limit: 1, default: 0
        t.integer  "KM",                   default: 0
        t.integer  "Edit",       limit: 1, default: 0
        t.datetime "InsertDate"
      end

      create_table "StKostenstelle", primary_key: "KostenstelleID", force: true do |t|
        t.string  "Kostenstelle",               limit: 10,                                          null: false
        t.decimal "FirmaID",                               precision: 10, scale: 0,                 null: false
        t.string  "Bemerkungen",                limit: 40
        t.string  "Stationsname",               limit: 30,                                          null: false
        t.string  "Adresse",                    limit: 20
        t.string  "Ort",                        limit: 20
        t.string  "Land",                       limit: 10
        t.string  "PLZ",                        limit: 10
        t.string  "Ansprechperson",             limit: 20
        t.string  "Tel1",                       limit: 20
        t.string  "Tel2",                       limit: 20
        t.string  "Fax",                        limit: 20
        t.string  "Email1",                     limit: 30
        t.string  "Email2",                     limit: 30
        t.string  "KostenStelleKontrollerCODE", limit: 6
        t.boolean "deaktiviert",                                                    default: false
        t.boolean "duplikat"
      end

      create_table "StLogin", primary_key: "LoginID", force: true do |t|
        t.decimal "FirmaID",                           precision: 10, scale: 0,                 null: false
        t.string  "Login",                  limit: 10,                                          null: false
        t.string  "Passwort",               limit: 10,                                          null: false
        t.string  "Vorname",                limit: 20
        t.string  "Nachname",               limit: 20
        t.string  "TelNR",                  limit: 20
        t.string  "FaxNR",                  limit: 20
        t.string  "EMail",                  limit: 60
        t.decimal "BerchtigungID",                     precision: 18, scale: 0
        t.decimal "UserGruppeID",                      precision: 18, scale: 0
        t.decimal "KostenstelleID_Berecht",            precision: 18, scale: 0
        t.decimal "KostenstelleID",                    precision: 18, scale: 0
        t.boolean "deaktiviert",                                                default: false
      end

      create_table "StUsergruppen", primary_key: "UserGruppenID", force: true do |t|
        t.string "GruppenBezeichnng", limit: 25
      end

      create_table "stWaehrung", primary_key: "ID", force: true do |t|
        t.string "Name", limit: 5, null: false
      end

      create_table "sysdiagrams", primary_key: "diagram_id", force: true do |t|
        t.string  "name",         limit: 128, null: false
        t.integer "principal_id",             null: false
        t.integer "version"
        t.binary  "definition"
      end

      add_index "sysdiagrams", ["principal_id", "name"], name: "UK_principal_name", unique: true

      create_table "tabMobileRsAUserLogin", id: false, force: true do |t|
        t.integer  "UserID",                     null: false
        t.datetime "Datum",                      null: false
        t.string   "ShortPhoneNumber", limit: 3
      end
    end
  end
end
