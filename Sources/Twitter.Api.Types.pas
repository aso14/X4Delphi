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
unit Twitter.Api.Types;

interface

uses
  System.Generics.Collections, System.SysUtils;

  const

  {$REGION 'Twitter Commands'}
    C_INIT       = 'INIT';
    C_APPEND     = 'APPEND';
    C_FINALIZE   = 'FINALIZE';
  {$ENDREGION}

  {$REGION 'Links'}
    CUrlAuth     = 'https://api.twitter.com/oauth/request_token';
    CRedirect    = 'https://api.twitter.com/oauth/authorize';
    CUrl         = 'https://api.twitter.com/2/tweets';
    CUrlMedia    = 'https://upload.twitter.com/1.1/media/upload.json';
    CCallBackURI = 'http://localhost:3000/auth/twitter/callback';
    CTmpUrl      = 'https://api.twitter.com/oauth/access_token';
  {$ENDREGION}

  CDefaultPort = 3000;

type

{Standard v1.1}

 TwitterMediaType = (VideoMP4,ImagePNG,ImageGIF);
 EventFlag = (EvTweet,EvWithTweet);

 ETwitter = class(Exception)
  private
    FStatus : Integer;
  public
    property Status : Integer read FStatus write FStatus;
 end;

TCoordinates = record
  Longitude: Double;
  Latitude: Double;
end;

TTwitterSize = class
  private
    Fw: Integer;
    Fh: Integer;
    Fresize: string;
  public
    property w: Integer read Fw write Fw;
    property h: Integer read Fh write Fh;
    property resize: string read Fresize write Fresize;
end;

{Media Object}

TTwitterMedia = class
  private
    Fdisplay_url: string;
    Fexpanded_url: string;
    Fid: Int64;
    Fid_str: string;
    Findices: TArray<Integer>;
    Fmedia_url: string;
    Fmedia_url_https: string;
    Fsize: TTwitterSize;
    Fsource_status_id: Int64;
    Fsource_status_id_str: Int64;
    Ftype: string;
    Furl: string;
  public
    property display_url: string read Fdisplay_url write Fdisplay_url;
    property expanded_url: string read Fexpanded_url write Fexpanded_url;
    property id: Int64 read Fid write Fid;
    property id_str: string read Fid_str write Fid_str;
    property indices: TArray<Integer> read Findices write Findices;
    property media_url: string read Fmedia_url write Fmedia_url;
    property media_url_https: string read Fmedia_url_https write Fmedia_url_https;
    property size: TTwitterSize read Fsize write Fsize;
    property source_status_id: Int64 read Fsource_status_id write Fsource_status_id;
    property source_status_id_str: Int64 read Fsource_status_id_str write Fsource_status_id_str;
    property &type: string read Ftype write Ftype;
    property url: string read Furl write Furl;
end;

TTwitterMediaSize = class
  private
    Fthumb:  TTwitterSize;
    Flarge:  TTwitterSize;
    Fmedium: TTwitterSize;
    Fsmall:  TTwitterSize;
  public
    property thumb: TTwitterSize read Fthumb write Fthumb;
    property large: TTwitterSize read Flarge write Flarge;
    property medium: TTwitterSize read Fmedium write Fmedium;
    property small: TTwitterSize read Fsmall write Fsmall;
end;

TTwitterUrl = class
  private
    Fdisplay_url: string;
    Fexpanded_url: string;
    Findices: TArray<Integer>;
    Furl: string;
    Fstatus: Integer;
    Ftitle: string;
    Fdescription: string;
  public
    property display_url: string read Fdisplay_url write Fdisplay_url;
    property expanded_url: string read Fexpanded_url write Fexpanded_url;
    property indices: TArray<Integer> read Findices write Findices;
    property url: string read Furl write Furl;
    property status: Integer read Fstatus write Fstatus;
    property title: string read Ftitle write Ftitle;
    property description: string read Fdescription write Fdescription;
end;

TTwitterUserMention = class
  private
    Fid: Int64;
    Fid_str: string;
    Findices: TArray<Integer>;
    Fname: string;
    Fscreen_name: string;
  public
    property id: Int64 read Fid write Fid;
    property id_str: string read Fid_str write Fid_str;
    property indices: TArray<Integer> read Findices write Findices;
    property name: string read Fname write Fname;
    property screen_name: string read Fscreen_name write Fscreen_name;
end;

TTwitterSymbol = class
  private
    Findices: TArray<Integer>;
    Ftext: string;
  public
    property indices: TArray<Integer> read Findices write Findices;
    property text: string read Ftext write Ftext;
end;

{Hashtag Object}
TTwitterHashtag = class
  private
    Findices: TArray<Integer>;
    Ftext: string;
  public
    property indices: TArray<Integer> read Findices write Findices;
    property text: string read Ftext write Ftext;
end;

TTwitterExtendedEntities = class
  private
    Fmedia: TArray<TTwitterMedia>;
  public
    property media: TArray<TTwitterMedia> read Fmedia write Fmedia;
end;

TTwitterEntities = class
  private
    Fhashtags: TArray<TTwitterHashtag>;
    Fmedia: TArray<TTwitterMedia>;
    Furls: TArray<TTwitterUrl>;
    Fuser_mentions: TArray<TTwitterUserMention>;
    Fsymbols: TArray<TTwitterSymbol>;
  public
    property hashtags: TArray<TTwitterHashtag> read Fhashtags write Fhashtags;
    property media: TArray<TTwitterMedia> read Fmedia write Fmedia;
    property urls: TArray<TTwitterUrl> read Furls write Furls;
    property user_mentions: TArray<TTwitterUserMention> read Fuser_mentions write Fuser_mentions;
    property symbols: TArray<TTwitterSymbol> read Fsymbols write Fsymbols;
end;

TTwitterCoordinates = class
  private
    Fcoordinates: TCoordinates;
    Ftype: string;
  public
    property coordinates: TCoordinates read Fcoordinates write Fcoordinates;
    property &type: string read Ftype write Ftype;
end;

TTwitterBoundingBox = class
  private
    Fcoordinates: TArray<TArray<TArray<TCoordinates>>>;
    Ftype: string;
  public
    property coordinates: TArray<TArray<TArray<TCoordinates>>> read Fcoordinates write Fcoordinates;
    property &type: string read Ftype write Ftype;
end;

TTwitterPlace = class
  private
    Fid: Int64;
    Furl: string;
    Fplace_type: string;
    Fname: string;
    Ffull_name: string;
    Fcountry_code: string;
    Fcountry: string;
    Fbounding_box: TTwitterBoundingBox;
    Fattributes: TObject;
  public
    property id: Int64 read Fid write Fid;
    property url: string read Furl write Furl;
    property place_type: string read Fplace_type write Fplace_type;
    property name: string read Fname write Fname;
    property full_name: string read Ffull_name write Ffull_name;
    property country_code: string read Fcountry_code write Fcountry_code;
    property country: string read Fcountry write Fcountry;
    property bounding_box: TTwitterBoundingBox read Fbounding_box write Fbounding_box;
    property attributes: TObject read Fattributes write Fattributes;
end;

TTwitterUser = class
  private
    Fid: Int64;
    Fid_str: string;
    Fname: string;
    Fscreen_name: string;
    Flocation: string;
    Furl: string;
    Fdescription: string;
    Fprotected: Boolean;
    Fverified: Boolean;
    Ffollowers_count: Integer;
    Ffriends_count: Integer;
    Flisted_count: Integer;
    Ffavourites_count: Integer;
    Fstatuses_count: Integer;
    Fcreated_at: string;
    Fprofile_banner_url: string;
    Fprofile_image_url_https: string;
    Fdefault_profile: Boolean;
    Fdefault_profile_image: Boolean;
    Fwithheld_in_countries: TArray<string>;
    Fwithheld_scope: string;
  public
    property id: Int64 read Fid write Fid;
    property id_str: string read Fid_str write Fid_str;
    property name: string read Fname write Fname;
    property screen_name: string read Fscreen_name write Fscreen_name;
    property location: string read Flocation write Flocation;
    property url: string read Furl write Furl;
    property description: string read Fdescription write Fdescription;
    property protected: Boolean read Fprotected write Fprotected;
    property verified: Boolean read Fverified write Fverified;
    property followers_count: Integer read Ffollowers_count write Ffollowers_count;
    property friends_count: Integer read Ffriends_count write Ffriends_count;
    property listed_count: Integer read Flisted_count write Flisted_count;
    property favourites_count: Integer read Ffavourites_count write Ffavourites_count;
    property statuses_count: Integer read Fstatuses_count write Fstatuses_count;
    property created_at: string read Fcreated_at write Fcreated_at;
    property profile_banner_url: string read Fprofile_banner_url write Fprofile_banner_url;
    property profile_image_url_https: string read Fprofile_image_url_https write Fprofile_image_url_https;
    property default_profile: Boolean read Fdefault_profile write Fdefault_profile;
    property default_profile_image: Boolean read Fdefault_profile_image write Fdefault_profile_image;
    property withheld_in_countries: TArray<string> read Fwithheld_in_countries write Fwithheld_in_countries;
    property withheld_scope: string read Fwithheld_scope write Fwithheld_scope;
end;

TTwitterRule = class
  private
    Ftag: string;
    Fid: Integer;
    Fid_str: string;
  public
    property tag: string read Ftag write Ftag;
    property id: Integer read Fid write Fid;
    property id_str: string read Fid_str write Fid_str;
end;

TTwitterScopes = class
  private
    Ffollowers: Boolean;
  public
    property followers: Boolean read Ffollowers write Ffollowers;
end;

TTwitterCurUserRetweet = class
  private
    Fid: Integer;
    Fid_str: string;
  public
    property id: Integer read Fid write Fid;
    property id_str: string read Fid_str write Fid_str;
end;

TTwitterTweet = class
  private
    Fcreated_at: string;
    Fid: Int64;
    Fid_str: string;
    Ftext: string;
    Fsource: string;
    Ftruncated: Boolean;
    Fin_reply_to_status_id: Int64;
    Fin_reply_to_status_id_str: string;
    Fin_reply_to_user_id: Int64;
    Fin_reply_to_user_id_str: string;
    Fin_reply_to_screen_name: string;
    Fuser: TTwitterUser;
    Fcoordinates: TTwitterCoordinates;
    Fplace: TTwitterPlace;
    Fquoted_status_id: Int64;
    Fquoted_status_id_str: string;
    Fis_quote_status: Boolean;
    Fquoted_status: TTwitterTweet;
    Fretweeted_status: TTwitterTweet;
    Fquote_count: Integer;
    Freply_count: Integer;
    Fretweet_count: Integer;
    Ffavorite_count: Integer;
    Fentities: TTwitterEntities;
    Fextended_entities: TTwitterExtendedEntities;
    Ffavorited: Boolean;
    Fretweeted: Boolean;
    Fpossibly_sensitive: Boolean;
    Ffilter_level: string;
    Flang: string;
    Fmatching_rules: TArray<TTwitterRule>;
    Fcurrent_user_retweet: TTwitterCurUserRetweet;
    Fscopes: TTwitterScopes;
    Fwithheld_copyright: Boolean;
    Fwithheld_in_countries: TArray<string>;
    Fwithheld_scope: string;
  public
    property created_at: string read Fcreated_at write Fcreated_at;
    property id: Int64 read Fid write Fid;
    property id_str: string read Fid_str write Fid_str;
    property text: string read Ftext write Ftext;
    property source: string read Fsource write Fsource;
    property truncated: Boolean read Ftruncated write Ftruncated;
    property in_reply_to_status_id: Int64 read Fin_reply_to_status_id write Fin_reply_to_status_id;
    property in_reply_to_status_id_str: string read Fin_reply_to_status_id_str write Fin_reply_to_status_id_str;
    property in_reply_to_user_id: Int64 read Fin_reply_to_user_id write Fin_reply_to_user_id;
    property in_reply_to_user_id_str: string read Fin_reply_to_user_id_str write Fin_reply_to_user_id_str;
    property in_reply_to_screen_name: string read Fin_reply_to_screen_name write Fin_reply_to_screen_name;
    property user: TTwitterUser read Fuser write Fuser;
    property coordinates: TTwitterCoordinates read Fcoordinates write Fcoordinates;
    property place: TTwitterPlace read Fplace write Fplace;
    property quoted_status_id: Int64 read Fquoted_status_id write Fquoted_status_id;
    property quoted_status_id_str: string read Fquoted_status_id_str write Fquoted_status_id_str;
    property is_quote_status: Boolean read Fis_quote_status write Fis_quote_status;
    property quoted_status: TTwitterTweet read Fquoted_status write Fquoted_status;
    property retweeted_status: TTwitterTweet read Fretweeted_status write Fretweeted_status;
    property quote_count: Integer read Fquote_count write Fquote_count;
    property reply_count: Integer read Freply_count write Freply_count;
    property retweet_count: Integer read Fretweet_count write Fretweet_count;
    property favorite_count: Integer read Ffavorite_count write Ffavorite_count;
    property entities: TTwitterEntities read Fentities write Fentities;
    property extended_entities: TTwitterExtendedEntities read Fextended_entities write Fextended_entities;
    property favorited: Boolean read Ffavorited write Ffavorited;
    property retweeted: Boolean read Fretweeted write Fretweeted;
    property possibly_sensitive: Boolean read Fpossibly_sensitive write Fpossibly_sensitive;
    property filter_level: string read Ffilter_level write Ffilter_level;
    property lang: string read Flang write Flang;
    property matching_rules: TArray<TTwitterRule> read Fmatching_rules write Fmatching_rules;
    property current_user_retweet: TTwitterCurUserRetweet read Fcurrent_user_retweet write Fcurrent_user_retweet;
    property scopes: TTwitterScopes read Fscopes write Fscopes;
    property withheld_copyright: Boolean read Fwithheld_copyright write Fwithheld_copyright;
    property withheld_in_countries: TArray<string> read Fwithheld_in_countries write Fwithheld_in_countries;
    property withheld_scope: string read Fwithheld_scope write Fwithheld_scope;
end;

TTwitterErrorDetail = class
  private
    Fmessage: string;
  public
    property &message: string read Fmessage write Fmessage;
end;

TTwitterAPIError = class
  private
    FErrors: TArray<TTwitterErrorDetail>;
    FTitle: string;
    FDetail: string;
    FTypeURL: string;
  public
    property Errors: TArray<TTwitterErrorDetail> read FErrors write FErrors;
    property Title: string read FTitle write FTitle;
    property Detail: string read FDetail write FDetail;
    property TypeURL: string read FTypeURL write FTypeURL;
end;

TTwitterImageInfo = class
  private
    Fimage_type: string;
    Fw: Integer;
    Fh: Integer;
  public
    property image_type: string read Fimage_type write Fimage_type;
    property w: Integer read Fw write Fw;
    property h: Integer read Fh write Fh;
  end;

  TTwitterVideoInfo = class
  private
    Fvideo_type: string;
  public
    property video_type: string read Fvideo_type write Fvideo_type;
  end;

  TTwitterProcessInfo = class
  private
    Fstate: string;
    Fprogress_percent: Integer;
  public
    property state: string read Fstate write Fstate;
    property progress_percent: Integer read Fprogress_percent write Fprogress_percent;
  end;

  TTwitterMediaInfo = class
  private
    Fmedia_id: Int64;
    Fmedia_id_string: string;
    Fsize: Integer;
    Fexpires_after_secs: Integer;
    Fmedia_key : string;
    Fimage: TTwitterImageInfo;
    Fvideo: TTwitterVideoInfo;
    Fprocessing_info : TTwitterProcessInfo;
  public
    property media_id: Int64 read Fmedia_id write Fmedia_id;
    property media_id_string: string read Fmedia_id_string write Fmedia_id_string;
    property size: Integer read Fsize write Fsize;
    property expires_after_secs: Integer read Fexpires_after_secs write Fexpires_after_secs;
    property media_key : string read Fmedia_key write Fmedia_key;
    property image: TTwitterImageInfo read Fimage write Fimage;
    property video: TTwitterVideoInfo read Fvideo write Fvideo;
    property processing_info : TTwitterProcessInfo read Fprocessing_info write Fprocessing_info;
  end;

 TTweetData = class
  private
    Fedit_history_tweet_ids: TArray<string>;
    Fid: string;
    Ftext: string;
  public
    property edit_history_tweet_ids: TArray<string> read Fedit_history_tweet_ids write Fedit_history_tweet_ids;
    property id: string read Fid write Fid;
    property text: string read Ftext write Ftext;
  end;

  TTweetResponse = class
  private
    Fdata: TTweetData;
  public
    property data: TTweetData read Fdata write Fdata;
  end;

   TTweetDataDelete = class
  private
    Fdeleted: Boolean;
  public
    property deleted: Boolean read Fdeleted write Fdeleted;
  end;

  TTweetRespDeleted = class
  private
    Fdata: TTweetDataDelete;
  public
    property data: TTweetDataDelete read Fdata write Fdata;
  end;

  TTwitterSign  = record
    oauth_token,
    oauth_token_secret,
    oauth_verifier : string;
    oauth_callbackcf :Boolean;
  end;

  TTwitterCredentials = record
   _ConsumerKey   : string;
   _ConsumerSecret: string;
   _AccessToken   : string;
   _TokenSecret   : string;
   _BearerToken   : string;
   _UserID        : string;
   _ScreenName    : string;
  end;

 TTwitterCrResult =  record
    ErrorReturn : ETwitter;
    xResult : TTweetResponse;
  end;

  EDuplicatedError = class(ETwitter);
  EInvalidOrExpiredToken = class(ETwitter);
  EUnauthorized = class(ETwitter);
  ETooManyRequests = class(ETwitter);
  EUnknownError = class(ETwitter);
  EFileSizeMismatch = class(ETwitter);
  EMediaUnrecognized = class (ETwitter);


implementation


end.
