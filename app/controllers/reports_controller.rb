class ReportsController < ApplicationController
  def create
    puts report_params[:chat_file].inspect

    # Create two tmp tables in DB (one for raw data and the other for processed data)
    # Read file and insert into tmp table
    # Process tmp table and insert into final tmp table
    # Execute queries against final tmp table
    # Delete tmp tables
    # Stores results and redirects to report page

    result = ApplicationRecord.connection.execute(<<~SQL)
      create temporary table raw_data (
        row text
      );
    SQL

    result = ApplicationRecord.connection.execute(<<~SQL)
      create temporary table processed_data (
        created_at timestamp,
        sender varchar(256),
        message text
      );
    SQL

    result = ApplicationRecord.connection.execute(<<~SQL)
      copy raw_data from '#{report_params[:chat_file].path}';
    SQL

    result = ApplicationRecord.connection.execute(<<~SQL)
      with processed as (
        select
          to_timestamp(
            unnest(regexp_match(row, '\\d+/\\d+/\\d+')) || ' ' || unnest(regexp_match(row, '\\d\\d:\\d\\d')),
            'MM/DD/YY HH24:MI'
          ) as created_at,
          unnest(regexp_match(row, '\\s-\\s(.*?):')) as sender,
          unnest(regexp_match(row, ':\\s(.+)\\Z')) as message
        from raw_data
      )

      insert into processed_data
      select *
      from processed
      where sender is not null;
    SQL

    result = ApplicationRecord.connection.execute(<<~SQL)
      select
        sender,
        count(*) as "cantidad de veces que se envió la palabra dormir"
      from
        processed_data
      where
        message ~ 'dormir'
      group by
        sender;
    SQL
  ensure
    ApplicationRecord.connection.execute(<<~SQL)
      drop table if exists raw_data;
    SQL

    ApplicationRecord.connection.execute(<<~SQL)
      drop table if exists processed_data;
    SQL
  end

  private

  def report_params
    params.require(:report).permit(:chat_file)
  end
end
