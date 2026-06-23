from bd_initialization.DataBase_models import SessionLocal

def get_session():
    bd=SessionLocal()
    try:
        yield bd
    finally :
        bd.close()