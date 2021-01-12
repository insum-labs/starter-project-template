set define off;

PROMPT CHANGE_ME data

declare
  l_json clob;
begin

  -- Load data in JSON object
  l_json := q'!
[
  {
    "CHANGE_ME_code": "CHANGEME",
    "CHANGE_ME_name": "CHANGEME",
    "CHANGE_ME_seq": 1
  }
]
!';


  for data in (
    select *
    from json_table(l_json, '$[*]' columns
      CHANGE_ME_code varchar2(4000) path '$.CHANGE_ME_code',
      CHANGE_ME_name varchar2(4000) path '$.CHANGE_ME_name',
      CHANGE_ME_seq number path '$.CHANGE_ME_seq'
    )
  ) loop
    
    -- Note: looping over each entry to make it easier to debug in case one entry is invalid
    -- If performance is an issue can move the loop's select statement into the merge statement
    merge into CHANGE_ME dest
      using (
        select
          data.CHANGE_ME_code CHANGE_ME_code
        from dual
      ) src
      on (1=1
        and dest.CHANGE_ME_code = src.CHANGE_ME_code
      )
    when matched then
      update
        set
          -- Don't update the value as it's probably a key/secure value
          -- Deletions are handled above
          dest.CHANGE_ME_name = data.CHANGE_ME_name,
          dest.CHANGE_ME_seq = data.CHANGE_ME_seq
    when not matched then
      insert (
        CHANGE_ME_code,
        CHANGE_ME_name,
        CHANGE_ME_seq,
        created_on,
        created_by)
      values(
        data.CHANGE_ME_code,
        data.CHANGE_ME_name,
        data.CHANGE_ME_seq,
        current_timestamp,
        'SYSTEM')
    ;
  end loop;

end;
/
