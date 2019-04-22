name        "dbcloner"
description "Clones database for preparation, used by pre-staging deploys"
maintainer  "CGA"
version     "1.0.0"

recipe "dbcloner::deploy", "Clones database"
recipe "dbcloner::remove", "Removes database"
