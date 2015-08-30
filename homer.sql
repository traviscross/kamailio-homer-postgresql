-- create_sipcapture.sql

CREATE TABLE sip_capture (
  id SERIAL NOT NULL,
  date TIMESTAMP WITHOUT TIME ZONE DEFAULT '1900-01-01 00:00:01' NOT NULL,
  micro_ts BIGINT NOT NULL DEFAULT '0',
  method VARCHAR(50) NOT NULL DEFAULT '',
  reply_reason VARCHAR(100) NOT NULL,
  ruri VARCHAR(200) NOT NULL DEFAULT '',
  ruri_user VARCHAR(100) NOT NULL DEFAULT '',
  from_user VARCHAR(100) NOT NULL DEFAULT '',
  from_tag VARCHAR(64) NOT NULL DEFAULT '',
  to_user VARCHAR(100) NOT NULL DEFAULT '',
  to_tag VARCHAR(64) NOT NULL,
  pid_user VARCHAR(100) NOT NULL DEFAULT '',
  contact_user VARCHAR(120) NOT NULL,
  auth_user VARCHAR(120) NOT NULL,
  callid VARCHAR(100) NOT NULL DEFAULT '',
  callid_aleg VARCHAR(100) NOT NULL DEFAULT '',
  via_1 VARCHAR(256) NOT NULL,
  via_1_branch VARCHAR(80) NOT NULL,
  cseq VARCHAR(25) NOT NULL,
  diversion VARCHAR(256), /* MySQL: NOT NULL */
  reason VARCHAR(200) NOT NULL,
  content_type VARCHAR(256) NOT NULL,
  auth VARCHAR(256) NOT NULL,
  user_agent VARCHAR(256) NOT NULL,
  source_ip VARCHAR(60) NOT NULL DEFAULT '',
  source_port INTEGER NOT NULL,
  destination_ip VARCHAR(60) NOT NULL DEFAULT '',
  destination_port INTEGER NOT NULL,
  contact_ip VARCHAR(60) NOT NULL,
  contact_port INTEGER NOT NULL,
  originator_ip VARCHAR(60) NOT NULL DEFAULT '',
  originator_port INTEGER NOT NULL,
  correlation_id VARCHAR(256) NOT NULL,
  proto INTEGER NOT NULL,
  family INTEGER NOT NULL,
  rtp_stat VARCHAR(256) NOT NULL,
  type INTEGER NOT NULL,
  node VARCHAR(125) NOT NULL,
  msg BYTEA NOT NULL,
  PRIMARY KEY (id,date)
);

CREATE INDEX ON sip_capture (ruri_user);
CREATE INDEX ON sip_capture (from_user);
CREATE INDEX ON sip_capture (to_user);
CREATE INDEX ON sip_capture (pid_user);
CREATE INDEX ON sip_capture (auth_user);
CREATE INDEX ON sip_capture (callid_aleg);
CREATE INDEX ON sip_capture (date);
CREATE INDEX ON sip_capture (callid);
CREATE INDEX ON sip_capture (source_ip);
CREATE INDEX ON sip_capture (destination_ip);

-- homer_users.sql

CREATE TABLE homer_hosts (
  id SERIAL NOT NULL,
  host VARCHAR(80) NOT NULL,
  name VARCHAR(100) NOT NULL,
  status SMALLINT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (host)
);

CREATE TABLE homer_logon (
  userid SERIAL NOT NULL,
  useremail VARCHAR(50) NOT NULL DEFAULT '',
  password VARCHAR(50) NOT NULL DEFAULT '',
  userlevel INTEGER NOT NULL DEFAULT '0',
  PRIMARY KEY (userid)
);

CREATE TABLE homer_nodes (
  id SERIAL NOT NULL,
  host VARCHAR(80) NOT NULL,
  dbname VARCHAR(100) NOT NULL,
  dbport VARCHAR(100) NOT NULL,
  dbusername VARCHAR(100) NOT NULL,
  dbpassword VARCHAR(100) NOT NULL,
  dbtables VARCHAR(100) NOT NULL DEFAULT 'sip_capture',
  name VARCHAR(100) NOT NULL,
  status SMALLINT NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (host)
);

CREATE TABLE homer_searchlog (
  id SERIAL NOT NULL,
  useremail VARCHAR(50) NOT NULL,
  date TIMESTAMP NOT NULL,
  search TEXT NOT NULL,
  PRIMARY KEY (id)
);
CREATE INDEX ON homer_searchlog (useremail);
CREATE INDEX ON homer_searchlog (date);

-- statistics.sql

CREATE TABLE alarm_data (
  id BIGSERIAL NOT NULL,
  create_date TIMESTAMP NOT NULL,
  type VARCHAR(50) NOT NULL DEFAULT '',
  total INTEGER NOT NULL,
  source_ip VARCHAR(150) NOT NULL DEFAULT '0.0.0.0',
  description VARCHAR(256) NOT NULL,
  status SMALLINT NOT NULL DEFAULT '1',
  PRIMARY KEY (id,create_date)
);
CREATE INDEX ON alarm_data (create_date);
CREATE INDEX ON alarm_data (type);

CREATE TABLE alarm_data_mem (
  id BIGSERIAL NOT NULL,
  create_date TIMESTAMP NOT NULL,
  type VARCHAR(50) NOT NULL DEFAULT '',
  total INTEGER NOT NULL,
  source_ip VARCHAR(150) NOT NULL DEFAULT '0.0.0.0',
  description VARCHAR(256) NOT NULL,
  status SMALLINT NOT NULL DEFAULT '1',
  PRIMARY KEY (id),
  UNIQUE (type,source_ip)
);
CREATE INDEX ON alarm_data (create_date);
CREATE INDEX ON alarm_data (type);

CREATE RULE inc_alarm_data_mem AS ON INSERT TO alarm_data_mem
  WHERE type = NEW.type AND source_ip = NEW.source_ip
  DO INSTEAD UPDATE alarm_data_mem SET total = total + 1;

CREATE stats_data (
  id BIGSERIAL NOT NULL,
  from_date TIMESTAMP NOT NULL,
  to_date TIMESTAMP NOT NULL,
  type VARCHAR(50) NOT NULL DEFAULT '',
  total INTEGER NOT NULL,
  PRIMARY KEY (id,from_date),
  UNIQUE (from_date,to_date,type)
);
CREATE INDEX ON stats_data (from_date);
CREATE INDEX ON stats_data (to_date);
CREATE INDEX ON stats_data (type);

CREATE TABLE stats_ip (
  id BIGSERIAL NOT NULL,
  from_date TIMESTAMP NOT NULL,
  to_date TIMESTAMP NOT NULL,
  method VARCHAR(50) NOT NULL DEFAULT '',
  source_ip VARCHAR(255) NOT NULL DEFAULT '0.0.0.0',
  total INTEGER NOT NULL,
  PRIMARY KEY (id,from_date),
  UNIQUE (from_date,to_date,method,source_ip)
);
CREATE INDEX ON stats_ip (from_date);
CREATE INDEX ON stats_ip (to_date);
CREATE INDEX ON stats_ip (method);

CREATE TABLE stats_ip_mem (
  id BIGSERIAL NOT NULL,
  create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  method VARCHAR(50) NOT NULL DEFAULT '',
  source_ip VARCHAR(255) NOT NULL DEFAULT '0.0.0.0',
  total INTEGER NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (method,source_ip)
);

CREATE RULE inc_stats_ip_mem AS ON INSERT TO stats_ip_mem
  WHERE method = NEW.method AND source_ip = NEW.source_ip
  DO INSTEAD UPDATE stats_ip_mem SET total = total + 1;

CREATE TABLE stats_method (
  id BIGSERIAL NOT NULL,
  from_date TIMESTAMP NOT NULL,
  to_date TIMESTAMP NOT NULL,
  method VARCHAR(50) NOT NULL DEFAULT '',
  auth SMALLINT NOT NULL DEFAULT '0',
  cseq VARCHAR(100) NOT NULL,
  totag SMALLINT NOT NULL,
  total INTEGER NOT NULL,
  PRIMARY KEY (id,from_date),
  UNIQUE (from_date,to_date,method,auth,totag,cseq)
);
CREATE INDEX ON stats_method (from_date);
CREATE INDEX ON stats_method (to_date);
CREATE INDEX ON stats_method (method);
CREATE INDEX ON stats_method (cseq);

CREATE TABLE stats_method_mem (
  id BIGSERIAL NOT NULL,
  create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  method VARCHAR(50) NOT NULL DEFAULT '',
  auth SMALLINT NOT NULL DEFAULT '0',
  cseq VARCHAR(100) NOT NULL,
  totag SMALLINT NOT NULL,
  total INTEGER NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (method,auth,totag, cseq)
);
CREATE INDEX ON stats_method (create_date);
CREATE INDEX ON stats_method (method);
CREATE INDEX ON stats_method (cseq);

CREATE TABLE stats_useragent (
  id BIGSERIAL NOT NULL,
  from_date TIMESTAMP NOT NULL,
  to_date TIMESTAMP NOT NULL,
  useragent VARCHAR(100) NOT NULL DEFAULT '',
  method VARCHAR(50) NOT NULL DEFAULT '',
  total INTEGER NOT NULL DEFAULT '0',
  PRIMARY KEY (id,from_date),
  UNIQUE (from_date,to_date,method,useragent)
);
CREATE INDEX ON stats_useragent (from_date);
CREATE INDEX ON stats_useragent (to_date);
CREATE INDEX ON stats_useragent (useragent);
CREATE INDEX ON stats_useragent (method);
CREATE INDEX ON stats_useragent (total);

CREATE TABLE stats_useragent_mem (
  id BIGSERIAL NOT NULL,
  create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  useragent VARCHAR(100) NOT NULL DEFAULT '',
  method VARCHAR(50) NOT NULL DEFAULT '',
  total INTEGER NOT NULL DEFAULT '0',
  PRIMARY KEY (id),
  UNIQUE (useragent,method)
);

CREATE RULE inc_stats_useragent_mem AS ON INSERT TO stats_useragent_mem
  WHERE useragent = NEW.useragent AND method = NEW.method
  DO INSTEAD UPDATE stats_useragent_mem SET total = total + 1;

CREATE TABLE alarm_config (
  id SERIAL NOT NULL,
  create_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  type VARCHAR(50) NOT NULL,
  value INTEGER NOT NULL,
  PRIMARY KEY (id),
  UNIQUE (type)
);
