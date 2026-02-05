{% macro convert_to_timezone(column_name, target_timezone='America/New_York') %}
    -- Assume the input timestamp is America/Sao_Paulo and convert to target timezone
    ({{ column_name }}::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE '{{ target_timezone }}')
{% endmacro %}