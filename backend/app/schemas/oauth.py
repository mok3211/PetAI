from pydantic import BaseModel

class OAuthGoogleRequest(BaseModel):
    id_token: str

class OAuthFacebookRequest(BaseModel):
    access_token: str

class OAuthWeChatRequest(BaseModel):
    code: str

