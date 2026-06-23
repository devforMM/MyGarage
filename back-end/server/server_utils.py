from passlib.context import CryptContext
from jose import jwt
from bd_initialization.DataBase_models import User
from datetime import datetime,timedelta,timezone
from fastapi import Depends,HTTPException
from fastapi.security import OAuth2PasswordBearer
from bd_initialization.Bridge import get_session
import os
SECRET_KEY=os.getenv("SECRET_KEY")
CRYPT_SCHEMES=os.getenv("CRYPT_SCHEMES")
ALGO=os.getenv("ALGO")


context=CryptContext(schemes=[CRYPT_SCHEMES],deprecated="auto")
def hash_password(password):
    return context.hash(password)
def verify_password(password,hashed_password):
    return context.verify(password,hashed_password)


def expire_time():
    return datetime.now(timezone.utc)+timedelta(minutes=300)
def create_token(data:dict):
    try:
        to_encode=data.copy()
        to_encode.update({
            "exp":expire_time()
        })
        return jwt.encode(to_encode,key=SECRET_KEY,algorithm=ALGO)
    except Exception:
     raise(HTTPException(status_code=401,detail="erreur lors de la creation du token"))
        


get_token=OAuth2PasswordBearer(tokenUrl="/login")
def get_curent__user(token:str=Depends(get_token),database=Depends(get_session)):
    try:
        user_data=jwt.decode(token,key="secret_key",algorithms=ALGO)
        if user_data:
            user=database.query(User).filter(User.id==user_data["id"]).first()
            return user
        else:
            raise HTTPException(status_code=404,detail="user introuvable")
    except Exception:
        raise HTTPException(status_code=500,detail="erreur lors du decodage du token")
    


