function search_obj_by_id(objs, _id){
  for(var idx in objs)
    if(objs[idx].id == _id)
      return objs[idx];
}

function append_options(_id, objs){
  objs.forEach(function(obj){
    $("#"+_id).append("<option value="+ obj.id +">"+ obj.name +"</option>");
  });
}

function reset_profile_options(profiles){
  $("#profile").empty()
  append_options("profile", profiles);
}

function reset_web_property_options(web_properties){
  $("#web_property").empty();
  append_options("web_property", web_properties);

  var selected_web_property_id = $('#web_property :selected').val();
  var selected_web_property = search_obj_by_id(web_properties, selected_web_property_id);
  var profiles = selected_web_property.profiles;
  reset_profile_options(profiles);
}

function reset_item_options(items){
  $("#item").empty();
  append_options("item", items);

  var selected_item_id = $('#item :selected').val();
  var selected_item = search_obj_by_id(items, selected_item_id);
  var web_properties = selected_item.web_properties;
  reset_web_property_options(web_properties);
}

function init_options(account_summary){
  var items = account_summary.items;
  reset_item_options(items)
}

$(function(){
  var account_summary = window.account_summary;
  init_options(account_summary);

  var items = account_summary.items;
  $("#item").change(function(){
    var selected_item_id = $('#item :selected').val();
    var selected_item = search_obj_by_id(items, selected_item_id);
    var web_properties = selected_item.web_properties;
    reset_web_property_options(web_properties);
  });
});
