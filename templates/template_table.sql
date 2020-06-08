prompt change_me
create table change_me (
  change_me_id number generated always as identity not null,
  change_me_code varchar2(30) not null,
  change_me_name varchar2(30) not null,
  change_me_seq number not null,
  created_on date default sysdate not null,
	created_by varchar2(255 byte) default
    coalesce(
      sys_context('APEX$SESSION','app_user'),
      regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*'),
      sys_context('userenv','session_user')
    )
    not null
    ,
  updated_on date,
  updated_by varchar2(255 byte)
);

comment on table change_me is 'CHANGEME';
comment on column change_me.CHANGEME is 'CHANGEME';

alter table change_me add constraint change_me_pk primary key (change_me_id);

alter table change_me add constraint change_me_uk1 unique(change_me_code);

alter table change_me add constraint change_me_ck1 check(change_me_code = trim(upper(change_me_code)));
alter table change_me add constraint change_me_ck2 check(change_me_seq = trunc(change_me_seq));

alter table change_me add constraint change_me_fk1 foreign key (changeme) references changeme_dest(changeme);

create index change_me_idx1 on change_me(changeme);
