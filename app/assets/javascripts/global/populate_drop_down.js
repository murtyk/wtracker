function populateDropdown(select, data) {
    select.html('');
    $.each(data, function(id, option) {
        select.append($('<option></option>').val(option.id).html(option.name));
    });
}
