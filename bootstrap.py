from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine

Base = automap_base()

engine = create_engine("postgresql://postgres:pass@db-training_db_1:5432/postgres")

Base.prepare(engine, reflect=True)

#User = Base.classes.user
#Address = Base.classes.address

session = Session(engine)


