$(() => {

  /**
   * Used to override simple inputs in the resource permissions controller
   * Allows to use more than one center when configuring :centers authorization handler
   * */
  const fields = [
    {
      url: "/admin/centers/centers",
      inputName: "[authorization_handlers_options][center][centers]"
    },
    {
      url: "/admin/centers/roles",
      inputName: "[authorization_handlers_options][center][roles]"
    },
    {
      url: "/admin/centers/scopes",
      inputName: "[authorization_handlers_options][center][scopes]"
    }
  ]

  const select2InputTags = (queryStr, url) => {
    const $input = $(queryStr)

    const $select = $(`<select class="${$input.attr("class")}" style="width:100%" multiple="multiple"><select>`);
    if ($input.val() !== "") {
      const values = $input.val().split(",");
      values.forEach((item) =>  {
        $select.append(`<option value="${item}" selected="selected">${item}</option>`)
      })
      ;
      // load text via ajax
      $.get(url, { ids: values }, (data) => {
        $select.val("");
        $select.contents("option").remove()
        data.forEach((item) => {
          $select.append(new Option(item.text, item.id, true, true));
        });
        $select.trigger("change");
      }, "json");
    }
    $select.insertAfter($input);
    $input.hide();

    $select.change(() => {
      $input.val($select.val().join(","));
    });

    return $select;
  };

  // Groups multiselect permissions
  fields.forEach((field) => {
    $(`input[name$='${field.inputName}']`).each((idx, input) => {
      select2InputTags(input, field.url).select2({
        ajax: {
          url: field.url,
          delay: 100,
          dataType: "json",
          processResults: (data) => {
            return {
              results: data
            }
          }
        },
        width: "100%",
        multiple: true,
        theme: "foundation"
      });
    });
  });
});
