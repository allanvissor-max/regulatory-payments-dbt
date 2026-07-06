{% test valid_currency_route(model, column_name) %}
    select *
    from {{ model }}
    where {{ column_name }} is null
       or instr({{ column_name }}, '-->') = 0
       or length(substr({{ column_name }}, 1, instr({{ column_name }}, '-->') - 1)) <> 3
       or length(substr({{ column_name }}, instr({{ column_name }}, '-->') + 3)) <> 3
{% endtest %}
