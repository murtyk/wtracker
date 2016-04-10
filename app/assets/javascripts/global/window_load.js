$(window).load(function() {
  var window_load_function = $('#page_data').data('window-load-function');
  if (window_load_function == null){
    return;
  }

  // find object
  var fn = window[window_load_function];

  // is object a function?
  if (typeof fn === "function"){
    console.log("calling " + window_load_function);
    fn();
  }
});
