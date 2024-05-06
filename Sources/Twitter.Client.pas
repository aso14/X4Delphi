{*******************************************************************************
  *                                                                             *
  *   Delphi Twitter (X) Library                                                *
  *                                                                             *
  *   Developer: Silas AIKO                                                     *
  *                                                                             *
  *   Description:                                                              *
  *   This Delphi library provides functionality for interacting with the       *
  *   Twitter (X) API v1 and v2.                                                *
  *                                                                             *
  *   Compatibility: VCL, FMX                                                   *
  *   Tested on Delphi: 11 Alexandria  CE                                       *
  *   Version: 1.1.0                                                            *
  *                                                                             *
  *   License: MIT License (See LICENSE file for details)                       *
  *                                                                             *
  *                                                                             *
  *******************************************************************************}
unit Twitter.Client;

interface

uses
  System.SysUtils, System.Classes, Twitter.Core, Twitter.Api.Types,
  Json, REST.Json,System.Net.Mime,FMX.Dialogs,System.Generics.Collections,
  IdContext,IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer,IdServerIOHandler,IdServerIOHandlerSocket,IdServerIOHandlerStack;

  type

  TTwitterAuthEvent        = procedure (AIsAuth : boolean) of object;
  TTwitterTweetSent        = procedure (ATweetId: string; ATweet:String; AError:ETwitter) of object;
  TTwitterTweetSentContent = procedure (ATweetMediaId: string; AError:ETwitter) of object;
  TTwitterTweetDeleted     = procedure (ADeleted : Boolean = false) of object;

  TTwitter = class(TComponent)
  private
    FConsumerKey      : string;
    FConsumerSecret   : string;
    FAccessToken      : string;
    FTokenSecret      : string;
    FBearerToken      : string;
    FCallBack         : TIdHTTPServer;
    FTwitterAuth      : TTwitterAuthEvent;
    FTweetSent        : TTwitterTweetSent;
    FTweetSentContent : TTwitterTweetSentContent;
    FUserID           : string;
    FScreenName       : string;

    procedure SetConsumerKey   (const AConsumerKey :String);
    procedure SetConsumerSecret(const AConsumerSecret :String);
    procedure SetAccessToken   (const AAccessToken :String);
    procedure SetTokenSecret   (const ATokenSecret :String);
    procedure SetBearerToken   (const ABearerToken :String);
    procedure HandleCallbackRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure RaiseSpecialError (AText:String; AStatus: Integer;AFunc : EventFlag);

    function  LvRequest(AMethod, AUrl: String; ABody: TStringStream; AParams : TStringList=nil):TTwitterCrResult;
    function  RedirectUser (AUrl:string): Boolean;
    function  IsErrorType(const JSONStr: string): ETwitter;
    function  GetFileSize(filePath: string): Int64;
    function  SetMediaType(AMediaType: TwitterMediaType) : string;
    function  UploadMedia(AMedia: String; AMediaType: TwitterMediaType): TTwitterMediaInfo;
    function  WaitForStatus(AJsonText : string): Boolean;

  protected

    procedure IsAuthenticated(AState:Boolean);
    procedure TweetSent(ATweetId : string; ATweetText: string; AError: ETwitter);
    procedure TweetSentContent(ATweetMediaId: string; AError:ETwitter);
    procedure SignData(AData:TTwitterCredentials);

  public

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure CreateTweet(AText: String);
    procedure CreateTweetWithContent(AText: String; AMedia:String; AMediaType:TwitterMediaType);
    procedure SignIn;

    function DeleteTweet(AId: string): Boolean;

    property UserID     : string read FUserID;
    property ScreenName : string read FScreenName;

  published
    property ConsumerKey    : String  read FConsumerKey      write SetConsumerKey;
    property ConsumerSecret : String  read FConsumerSecret   write SetConsumerSecret;
    property AccessToken    : String  read FAccessToken      write SetAccessToken;
    property TokenSecret    : String  read FTokenSecret      write SetTokenSecret;
    property BearerToken    : String  read FBearerToken      write SetBearerToken;
    property OnAuthenticated        : TTwitterAuthEvent        read FTwitterAuth      write FTwitterAuth;
    property OnTweetSent            : TTwitterTweetSent        read FTweetSent        write FTweetSent;
    property OnTweetSentWithContent : TTwitterTweetSentContent read FTweetSentContent write FTweetSentContent;
  end;

procedure Register;

implementation

uses ShellAPI, Windows;

procedure Register;
begin
  RegisterComponents('Bunker X', [TTwitter]);
end;

{ TTwitter }
constructor TTwitter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCallBack := TIdHTTPServer.Create(Self);
  FCallBack.DefaultPort  := CDefaultPort;
  FCallBack.OnCommandGet := HandleCallbackRequest;
  FCallBack.Active := True;
end;

procedure TTwitter.CreateTweet(AText: string);
var
  RequestBodyStream: TStringStream;
  JsonObject: TJSONObject;
begin

  {$REGION 'Variable Initialization'}
    RequestBodyStream := TStringStream.Create('');
    JsonObject := TJSONObject.Create;
  {$ENDREGION}

  try

    {$REGION 'Input Validation'}
    if AText.IsEmpty then
    begin
      RaiseSpecialError('Invalid Request: Empty tweet text.',400,EvTweet);
      Exit;
    end;
    {$ENDREGION}

    {$REGION 'Create JSON Object'}
    JsonObject.AddPair('text', AText);
    RequestBodyStream.WriteString(JsonObject.ToJSON);
    RequestBodyStream.Position := 0;
    {$ENDREGION}

    {$REGION 'Send Tweet Request'}
    ClientBase.ContentType := 'application/json';
    var Response := LvRequest('POST', CUrl, RequestBodyStream);

    if Response.ErrorReturn = nil then
      TweetSent(Response.xResult.data.id, Response.xResult.data.text, Response.ErrorReturn)
    else
      TweetSent('', '', Response.ErrorReturn);
    {$ENDREGION}
  except
    {$REGION 'Error Handling'}
    on E: Exception do
      raise Exception.Create('Error creating tweet: ' + E.Message);
    {$ENDREGION}
  end;

    {$REGION 'Clean Up'}
    RequestBodyStream.Free;
    JsonObject.Free;
    {$ENDREGION}
end;


procedure TTwitter.CreateTweetWithContent(AText: String; AMedia: String; AMediaType: TwitterMediaType);
var
  LMediaInfo: TTwitterMediaInfo;
  LResponse: string;
  LJsonObj: TJSONObject;
begin

  LMediaInfo := TTwitterMediaInfo.Create;
  {$REGION 'Upload Media'}
  if AMedia <> '' then
  begin
     LMediaInfo   := UploadMedia(AMedia, AMediaType);
     if LMediaInfo = nil then Exit;
  end;
  {$ENDREGION}

  {$REGION 'Tweet'}
   var LBody := TStringStream.Create;
   LJsonObj  := TJSONObject.Create;
   try
    LJsonObj.AddPair('text',AText);
    LJsonObj.AddPair('media', TJSONObject.Create.AddPair('media_ids',
    TJSONArray.Create.Add(LMediaInfo.media_id_string)));

    LBody.WriteString(LJsonObj.ToJSON);
    LBody.Position := 0;
    LResponse := HTTPPost('POST',CUrl,LBody);

    var Err := IsErrorType(LResponse);
    if not (Err=nil) then
    begin
      TweetSentContent('',Err);
      Exit;
    end;

    if not (LResponse.IsEmpty) then
    begin
      var LResp := TJSON.JsonToObject<TTweetResponse>(LResponse, [joIgnoreEmptyArrays, joIgnoreEmptyStrings]);
      var LFlag := LResp.data.id;
      TweetSentContent(LFlag,nil);
    end;
   except
     on E:Exception do  RaiseSpecialError('Invalid Request: One or more parameters to your request was invalid.',400,EvWithTweet) ;
   end;
  {$ENDREGION}

  LBody.DisposeOf;
  LJsonObj.DisposeOf;
end;



function TTwitter.DeleteTweet(AId: string): Boolean;
begin
  var tmpUrl := CUrl+'/'+AId;
  try
    result := HTTPDelete(tmpUrl);
   except
    raise Exception.Create('Error Message');
  end;
end;

destructor TTwitter.Destroy;
begin
  if Assigned(FCallBack) then FCallBack.DisposeOf;
  CloseTwitterClient;
  inherited;
end;

function TTwitter.GetFileSize(filePath: string): Int64;
var
 LFile : TFileStream;
begin
  LFile := TFileStream.Create(filePath, fmOpenRead or fmShareExclusive);
  try
    Result := LFile.Size;
  finally
    LFile.Free;
  end;
end;

procedure TTwitter.HandleCallbackRequest(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Params: TStringList;
  OAuthVerifier: string;
begin
  try
    {$REGION 'URL Validation and Resource Disposal'}
    if URLContains(ARequestInfo.QueryParams) then
    begin
      AResponseInfo.ResponseNo := 404;
      TThread.Synchronize(nil,procedure
      begin
        IsAuthenticated(False);
      end);
      FCallBack.StopListening;
      Exit;
    end;
    {$ENDREGION}

    {$REGION 'Callback Handling'}
    if ARequestInfo.URI = '/auth/twitter/callback' then
    begin
      Params := TStringList.Create;
      try
        Params.Delimiter := '&';
        Params.StrictDelimiter := True;
        Params.DelimitedText := ARequestInfo.QueryParams;

        OAuthVerifier := Params.Values['oauth_verifier'];

        if (LRespToken.oauth_token = Params.Values['oauth_token']) then
        begin
          AResponseInfo.ResponseText := '- You are authenticated !';

          Params.Clear;
          Params.AddPair('oauth_verifier', OAuthVerifier);
          Params.AddPair('oauth_token', LRespToken.oauth_token);

          // Assuming POST method returns the response as a string
          Params.DelimitedText := HTTPPost('POST', CTmpUrl, nil, Params);

          // Extracting user information from the response
          User._AccessToken := Params.Values['oauth_token'];
          User._TokenSecret := Params.Values['oauth_token_secret'];
          User._UserID := Params.Values['user_id'];
          User._ScreenName := Params.Values['screen_name'];

          // Sign the data
          SignData(User);

          TThread.Synchronize(nil,
            procedure
            begin
              IsAuthenticated(True);
            end);
        end
        else
          AResponseInfo.ResponseNo := 404;
      finally
        Params.Free;
      end;
      FCallBack.StopListening;
    end;
    {$ENDREGION}

    {$REGION 'Fallback Handling'}
    if ARequestInfo.URI <> '/auth/twitter/callback' then
    begin
      AResponseInfo.ResponseNo := 404;
      TThread.Synchronize(nil,procedure
      begin
        IsAuthenticated(False);
      end);
      FCallBack.StopListening;
      Exit;
    end;
    {$ENDREGION}
  except
    on E: Exception do
    begin
      AResponseInfo.ResponseNo := 500;
      AResponseInfo.ResponseText := 'An error occurred: ' + E.Message;
    end;
  end;

end;


procedure TTwitter.IsAuthenticated(AState: Boolean);
begin
  if Assigned(FTwitterAuth) then FTwitterAuth(AState);
end;

function TTwitter.IsErrorType(const JSONStr: string): ETwitter;
var
  JSONObject: TJSONObject;
  Status: Integer;
  Errors: TJSONArray;
  Title, ErrorStr: string;
begin
  Result := nil;
  JSONObject := TJSONObject.ParseJSONValue(JSONStr) as TJSONObject;
  try
    {$REGION 'Parse JSON Response'}
    if Assigned(JSONObject) then
    begin
      if JSONObject.TryGetValue<Integer>('status', Status) then
      begin
        case Status of
          403:
          begin
            Result := EDuplicatedError.Create('Duplicated Error');
            Result.Status := 403;
          end;
          401:
          begin
            Result := EUnauthorized.Create('Unauthorized');
            Result.Status := 401;
          end;
          429:
          begin
            Result := ETooManyRequests.Create('Too Many Requests');
            Result.Status := 429;
          end;
        end;
      end
      else if JSONObject.TryGetValue<TJSONArray>('errors', Errors) then
      begin
        if Errors.Count > 0 then
        begin
          if Errors.Items[0].TryGetValue<Integer>('code', Status) then
          begin
            case Status of
              89:
              begin
                Result := EInvalidOrExpiredToken.Create('Invalid or Expired Token');
                Result.Status := 89;
              end;
              38 :
              begin
                Result := EInvalidOrExpiredToken.Create('media_id or media_key parameter is missing.');
                Result.Status := 38;
              end;
            end;
          end;
        end;
      end
      else if JSONObject.TryGetValue<string>('title', Title) then
      begin
        if Title = 'Forbidden' then
        begin
          Result := EDuplicatedError.Create('Duplicated Error');
          Result.Status := 403;
        end;
      end
      else if JSONObject.TryGetValue<string>('error',ErrorStr) then
      begin
         if ErrorStr = 'Segments do not add up to provided total file size.'then
        begin
          Result := EFileSizeMismatch.Create(ErrorStr);
          Result.Status := 14;
        end;
        if ErrorStr = 'media type unrecognized.' then
        begin
          Result := EMediaUnrecognized.Create(ErrorStr);
          Result.Status := 15;
        end;
      end;
    end;
    {$ENDREGION}
  finally
    JSONObject.Free;
  end;
end;


function TTwitter.LvRequest(AMethod, AUrl: string; ABody: TStringStream;
  AParams: TStringList): TTwitterCrResult;
var
  LResponse: string;
  LtmpResult: TTwitterCrResult;
begin
  result := LtmpResult;
  try
    {$REGION 'Request Initialization'}
    LtmpResult.xResult := nil;
    {$ENDREGION}

    {$REGION 'Send Request and Process Response'}
    LResponse := HTTPPost(AMethod, AUrl, ABody, nil);
    LtmpResult.ErrorReturn := IsErrorType(LResponse);
    if LtmpResult.ErrorReturn = nil then
      LtmpResult.xResult := TJSON.JsonToObject<TTweetResponse>(LResponse, [joIgnoreEmptyArrays, joIgnoreEmptyStrings]);
    {$ENDREGION}

    Result := LtmpResult;
  except
    {$REGION 'Exception Handling'}
    on E: Exception do
    begin
      {$IFDEF VCL}
      ShowMessage('Error TNetHTTPClient : ' + E.Message);
      {$ENDIF}
      {$IFDEF FMX}
      ShowMessage('Error TNetHTTPClient : ' + E.Message);
      {$ENDIF}
    end;
    {$ENDREGION}
  end;
end;


procedure TTwitter.RaiseSpecialError(AText: String; AStatus: Integer; AFunc:EventFlag);
var
 LError : ETwitter;
begin
 LError := ETwitter.Create(AText);
 LError.Status := AStatus;
 case AFunc of
  EvTweet : TweetSent('','',LError);
  EvWithTweet: TweetSentContent('',LError);
 end;
end;

function TTwitter.RedirectUser(AUrl: string): Boolean;
var
  HInst: NativeUInt;
begin
{$IFDEF MSWINDOWS}
  HInst := ShellExecute(0, 'open', PChar(AUrl), nil, nil, SW_SHOWNORMAL);
  Result := (HInst>32) or (HInst = SE_ERR_NOASSOC);
{$ENDIF}
 end;

procedure TTwitter.SetAccessToken(const AAccessToken: String);
begin
  FAccessToken      := AAccessToken;
  User._AccessToken := AAccessToken;
end;

procedure TTwitter.SetBearerToken(const ABearerToken: String);
begin
  FBearerToken      := ABearerToken;
  User._BearerToken := ABearerToken;
end;

procedure TTwitter.SetConsumerKey(const AConsumerKey: String);
begin
  FConsumerKey      := AConsumerKey;
  User._ConsumerKey := AConsumerKey;
end;

procedure TTwitter.SetConsumerSecret(const AConsumerSecret: String);
begin
  FConsumerSecret      := AConsumerSecret;
  User._ConsumerSecret := AConsumerSecret;
end;

function TTwitter.SetMediaType(AMediaType: TwitterMediaType): string;
begin
  case AMediaType of
    VideoMP4: Result := 'video/mp4';
    ImagePNG: Result := 'image/png';
    ImageGIF: Result := 'image/gif';
    else Result := 'image/png';
  end;
end;

procedure TTwitter.SetTokenSecret(const ATokenSecret: String);
begin
 FTokenSecret      := ATokenSecret;
 User._TokenSecret := ATokenSecret;
end;

procedure TTwitter.SignData(AData: TTwitterCredentials);
begin
  FConsumerKey   := AData._ConsumerKey;
  FConsumerSecret:= AData._ConsumerSecret;
  FAccessToken   := AData._AccessToken;
  FTokenSecret   := Adata._TokenSecret;
  FBearerToken   := AData._BearerToken;
  FUserID        := AData._UserID;
  FScreenName    := AData._ScreenName;
end;

procedure TTwitter.SignIn;
var
  LParam: TStringList;
  Resp, RedirectURL: string;
begin
  LParam := TStringList.Create;
  LParam.Delimiter := '&';
  LParam.StrictDelimiter := True;
  try
    {$REGION 'Request OAuth Token'}
    Resp := HTTPPost('POST', CUrlAuth, nil);
    if Resp.IsEmpty then Exit;
    LParam.DelimitedText := Resp;
    LRespToken.oauth_token := LParam.Values['oauth_token'];
    LRespToken.oauth_token_secret := LParam.Values['oauth_token_secret'];
    LRespToken.oauth_callbackcf := LParam.Values['oauth_callback_confirmed'].ToBoolean;
    {$ENDREGION}

    {$REGION 'Handle OAuth Callback Confirmation'}
    if LRespToken.oauth_callbackcf then
    begin
      try
        FCallBack.StartListening;
        RedirectURL := Format('%s?%s', [CRedirect, LParam.DelimitedText]);
        RedirectUser(RedirectURL);
      except
        on E: Exception do FCallBack.Free;
      end;
    end;
    {$ENDREGION}
  except
    {$REGION 'Exception Handling'}
    on E: Exception do
    begin
      raise Exception.Create('Error signing in: ' + E.Message);
    end;
    {$ENDREGION}
  end;
  LParam.Free;
end;


procedure TTwitter.TweetSent(ATweetId : string; ATweetText: string; AError: ETwitter);
begin
  if Assigned(FTweetSent) then FTweetSent(ATweetId, ATweetText, AError);
end;

procedure TTwitter.TweetSentContent(ATweetMediaId: string; AError:ETwitter);
begin
  if Assigned(FTweetSentContent) then FTweetSentContent(ATweetMediaId,AError);
end;

function TTwitter.UploadMedia(AMedia: String;
  AMediaType: TwitterMediaType): TTwitterMediaInfo;
var
  LQuery: TStringList;
  LParams: TMultipartFormData;
  LResponse: string;
  LObj: TTwitterMediaInfo;
  LCount: Integer;
begin
   Result := nil;
  {$REGION 'Initialization'}
   LQuery := TStringList.Create;
   LParams := TMultipartFormData.Create;
  {$ENDREGION}
  try
  {$REGION 'Set Media Type'}
   var LTypeMedia := SetMediaType(AMediaType);
   var LFileSize  := GetFileSize(AMedia);

   if (LFileSize > 5242880) then
   begin
     RaiseSpecialError('',14,EvWithTweet);
     Exit;
   end;
  {$ENDREGION}

  {$REGION 'Uploading < 5MB'}
   LQuery.AddPair('command',C_INIT);
   LQuery.AddPair('total_bytes',LFileSize.ToString);
   LQuery.AddPair('media_type',LTypeMedia);

   var LPath := Format('?command=%s&total_bytes=%s&media_type=%s',
                [C_INIT, LFileSize.ToString, URLEncode(LTypeMedia)]);
   LResponse := HTTPPostFile(CUrlMedia, LParams, LPath, LQuery);
   LObj := TJSON.JsonToObject<TTwitterMediaInfo> (LResponse,[joIgnoreEmptyArrays,joIgnoreEmptyStrings]);

   if (LObj.media_id <= 0) then
   begin
    RaiseSpecialError('Invalid ID',400,EvWithTweet) ;
    Exit;
   end;

   LQuery.Clear;
   LQuery.AddPair('command',C_APPEND);
   LQuery.AddPair('media_id',LObj.media_id_string);
   LQuery.AddPair('segment_index','0');
   LParams.AddFile('media',AMedia);

   LPath := Format('?command=%s&media_id=%s&segment_index=%d',[C_APPEND, LObj.media_id_string, 0]);
   LResponse := HTTPPostFile(CUrlMedia, LParams, LPath, LQuery);
   LParams.DisposeOf;

   LQuery.Clear;
   LQuery.AddPair('command', C_FINALIZE);
   LQuery.AddPair('media_id', LObj.media_id_string);

   LParams := TMultipartFormData.Create;
   LPath := Format('?command=%s&media_id=%s', [C_FINALIZE, LObj.media_id_string]);
   LResponse := HTTPPostFile(CUrlMedia, LParams, LPath, LQuery);

   var Err := IsErrorType (LResponse);

   if not (Err=nil) then
   begin
    TweetSentContent('', Err);
    Exit;
   end;

  for LCount := 1 to CLimit_wait do
  begin
    LResponse := HTTPPostFile(CUrlMedia, LParams, LPath, LQuery);
    if WaitForStatus(LResponse) then break;
  end;

  if (LCount>=CLimit_wait)  then
  begin
    RaiseSpecialError('',14,EvWithTweet);
    Exit;
  end;

   Result := TJSON.JsonToObject<TTwitterMediaInfo>(LResponse, [joIgnoreEmptyArrays, joIgnoreEmptyStrings]);
  {$ENDREGION}

  finally
    LQuery.DisposeOf;
    LParams.DisposeOf;
  end;

end;

function TTwitter.WaitForStatus(AJsonText : string): Boolean;
var
  LObj: TJSONObject;
  LProcess, LImage: TJSONObject;
  LStateValue: string;
begin
  Result := false;
  LObj := TJSONObject.ParseJSONValue(AJsonText) as TJSONObject;
  try
    if Assigned(LObj) then
    begin
      if LObj.TryGetValue<TJSONObject>('processing_info', LProcess) then
      begin
          if LProcess.TryGetValue<string>('state', LStateValue) then
          begin
            if SameText(LStateValue, 'succeeded') then
            begin
              Result := True;
              Exit;
            end;
          end;
          Sleep(1000);
      end;
      if LObj.TryGetValue<TJSONObject>('image', LImage) then
      begin
      Result := True;
      Exit;
      end;
    end;
  finally
    LObj.Free;
  end;
end;


end.

