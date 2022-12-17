Query.find_or_initialize_by(name: "Cantidad de mensajes").update!(query: <<~SQL)
  select
    sender,
    count(*)
  from
    <%= table %>
  group by
    sender;
SQL

Query.find_or_initialize_by(name: "Cantidad de emojis").update!(query: <<~SQL)
  select
    sender,
    count(*)
  from
    <%= table %>
  where
    message ~ '[\U0001F300-\U0001F6FF]'
  group by
    sender;
SQL

Query.find_or_initialize_by(name: "Cantidad de links enviados").update!(query: <<~SQL)
  select
    sender,
    count(*)
  from
    <%= table %>
  where
    message ~ 'https?://'
  group by
    sender;
SQL

Query.find_or_initialize_by(name: "El primer mensaje fue").update!(query: <<~SQL)
  select
    sender,
    min(created_at) as "primer mensaje"
  from
    <%= table %>
  group by
    sender;
SQL

Query.find_or_initialize_by(name: "El día que más hablamos").update!(query: <<~SQL)
  select
    date_trunc('day', created_at) as "día",
    count(*)
  from
    <%= table %>
  group by
    date_trunc('day', created_at)
  order by
    count(*) desc
  limit 1;
SQL

Query.find_or_initialize_by(name: "El día de la semana con más mensajes en promedio").update!(query: <<~SQL)
  select
    to_char(created_at, 'Day') as "día",
    round(avg(count), 2)
  from (
    select
      date_trunc('day', created_at) as created_at,
      count(*)
    from
      <%= table %>
    group by
      date_trunc('day', created_at)
  ) as counts
  group by
    to_char(created_at, 'Day')
  order by
    avg(count) desc
  limit 1;
SQL

Query.find_or_initialize_by(name: "El día de la semana con menos mensajes en promedio").update!(query: <<~SQL)
  select
    to_char(created_at, 'Day') as "día",
    round(avg(count), 2)
  from (
    select
      date_trunc('day', created_at) as created_at,
      count(*)
    from
      <%= table %>
    group by
      date_trunc('day', created_at)
  ) as counts
  group by
    to_char(created_at, 'Day')
  order by
    avg(count)
  limit 1;
SQL

Query.find_or_initialize_by(name: "Cantidad de mensajes diarios en promedio por persona").update!(query: <<~SQL)
  select
    sender,
    round(avg(count), 2)
  from (
    select
      sender,
      date_trunc('day', created_at) as created_at,
      count(*)
    from
      <%= table %>
    group by
      sender,
      date_trunc('day', created_at)
  ) as counts
  group by
    sender
  order by
    avg(count) desc;
SQL

Query.find_or_initialize_by(name: "Quién se ríe más").update!(query: <<~SQL)
  select
    sender,
    count(*)
  from
    <%= table %>
  where
    message ~ '(jaja[ja]*|jeje[je]*|jiji[ji]*|haha[ha]*|hehe[he]*)'
  group by
    sender
  order by
    count(*) desc;
SQL

Query.find_or_initialize_by(name: "Las 10 palabras más usadas").update!(query: <<~SQL)
  with counts as (
    select
      sender,
      word,
      count(*) as count
    from (
      select
        sender,
        regexp_split_to_table(lower(message), '\W+') as word
      from
        <%= table %>
    ) as words
    where
      word not in ('a', 'de', 'el', 'en', 'la', 'lo', 'que', 'se', 'un', 'una', 'con', 'pero', 'para', 'los', 'las', 'por')
      and length(word) > 2
      and word !~* 'jaja[ja]*'
    group by
      sender,
      word
    order by
      count(*) desc
  )
  (select * from counts where sender = '<%= senders[0] %>' limit 5)
  union all
  (select * from counts where sender = '<%= senders[1] %>' limit 5)
  order by count desc;
SQL
