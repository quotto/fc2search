# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
add_user = -> 
  $user_array = $("div.user_input")
  if $user_array.length < 10 
    $new_user_input = $('<div class="user_input"></div>')
    $new_user_input.append('<input type="text" class="form-control" name="user[]" placeholder="除外するユーザを指定"></input>')
    $new_user_input.append('<span class="glyphicon glyphicon-plus user-plus" aria-hidden="true" onclick="add_user()"></span>')
    $new_user_input.append('<span class="glyphicon glyphicon-minus user-minus" aria-hidden="true" onclick="remove_user()"></span>')
    $user_array.parent().append($new_user_input) 

remove_user = ->
  $(event.target).parent().remove()

window.add_user = add_user
window.remove_user = remove_user



