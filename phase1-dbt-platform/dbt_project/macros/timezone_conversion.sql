{% macro convert_to_timezone(column_name, target_timezone='America/New_York') %}
    {% if target.type == 'snowflake' %}
        CONVERT_TIMEZONE('America/Sao_Paulo', '{{ target_timezone }}', {{ column_name }})
    {% else %}
        ({{ column_name }}::TIMESTAMP AT TIME ZONE 'America/Sao_Paulo' AT TIME ZONE '{{ target_timezone }}')
    {% endif %}
{% endmacro %}