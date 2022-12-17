class ReportsController < ApplicationController
  def create
    puts report_params[:chat_file].inspect

    # Create two tmp tables in DB (one for raw data and the other for processed data)
    # Read file and insert into tmp table
    # Process tmp table and insert into final tmp table
    # Execute queries against final tmp table
    # Delete tmp tables
    # Stores results and redirects to report page

    report = Report.create!
    sql_uuid = report.uuid.gsub('-', '_')

    result = ApplicationRecord.connection.execute(<<~SQL)
      create temporary table raw_data_#{sql_uuid} (
        row text
      );
    SQL

    result = ApplicationRecord.connection.execute(<<~SQL)
      create temporary table processed_data_#{sql_uuid} (
        created_at timestamp,
        sender varchar(256),
        message text
      );
    SQL

    result = ApplicationRecord.connection.execute(<<~SQL)
      copy raw_data_#{sql_uuid} from '#{report_params[:chat_file].path}';
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
        from raw_data_#{sql_uuid}
      )

      insert into processed_data_#{sql_uuid}
      select *
      from processed
      where sender is not null
      and message not like 'null' -- These are instant photos
      and message not like '%<Media omitted>'
    SQL

    variables = {
      table: "processed_data_#{sql_uuid}"
    }

    Query.find_each do |query|
      query_sql = query.to_sql(variables)
      result = ApplicationRecord.connection.execute(query_sql)
      QueryExecution.create!(
        query: query_sql,
        query_name: query.name,
        report: report,
        result: result
      )
    end

    redirect_to report
  ensure
    ApplicationRecord.connection.execute(<<~SQL)
      drop table if exists raw_data_#{sql_uuid};
    SQL

    ApplicationRecord.connection.execute(<<~SQL)
      drop table if exists processed_data_#{sql_uuid};
    SQL
  end

  def show
    @report = Report.find_by!(uuid: params[:uuid])
  end

  private

  def report_params
    params.require(:report).permit(:chat_file)
  end
end
