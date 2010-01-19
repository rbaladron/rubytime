var Users = {
  init: function() {
    Users._initValidation();
    Users._initUserTypeCombo();
    if ($('.box').html() == "") {
      $('#secondary .box').hide();
    }
  },
  
  _initValidation: function() {
    // add login validation method
    function loginFormat(value, element, params) {
      return this.optional(element) || (/^[\w_\-]{3,20}$/).test(value);
    }

    $.validator.addMethod('login', loginFormat,
      "Login should have between 3 and 20 characters including letters, digits, hyphen or underscore.");

    // add validation to form
    $('#user_form').validate({
      rules: {
        "user[name]": {
          required: true
        },
        "user[login]": {
          required: true,
          login: true
        },
        "user[email]": {
          required: true,
          email: true
        },
        "user[password]": {
          required: function(element) {
            var password_entered = element && element.value != "";
            var action = $("#user_form").attr("action");
            var editing = (/\d+$/).test(action);
            return password_entered || !editing;
          },
          minlength: 6
        },
        "user[password_confirmation]": {
          equalTo: "#user_password"
        }
      }
    });
  },
  
  _initUserTypeCombo: function() {
    $("#user_class_name").change(function() {
      var client = $("#user_client_id").parent();
      var role = $("#user_role_id").parent();

      if ($(this).val() == 'Employee') {
        client.hide();
        role.show();
      } else {
        role.hide();
        client.show();
      }
    });
  }
};

$(Users.init);
