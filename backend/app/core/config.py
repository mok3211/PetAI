from typing import List, Union, Optional
from pydantic import field_validator
from pydantic_settings import BaseSettings
from pydantic import BaseModel
from pydantic import ConfigDict
from pydantic import model_validator
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "PetAI"
    API_V1_STR: str = "/api/v1"
    BACKEND_CORS_ORIGINS: List[str] = []
    SECRET_KEY: str = "devsecret"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    DATABASE_URL: Optional[str] = None
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: int = 5432
    POSTGRES_DB: str = "petai"
    POSTGRES_USER: str = "petai"
    POSTGRES_PASSWORD: str = "petai"
    GOOGLE_CLIENT_ID: Optional[str] = None
    FACEBOOK_APP_ID: Optional[str] = None
    FACEBOOK_APP_SECRET: Optional[str] = None
    WECHAT_APP_ID: Optional[str] = None
    WECHAT_APP_SECRET: Optional[str] = None
    OAUTH_DEV_ALLOW: bool = True

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    @model_validator(mode="after")
    def assemble_database_url(self):
        if not self.DATABASE_URL:
            self.DATABASE_URL = (
                f"postgresql+psycopg2://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
                f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
            )
        return self

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()
