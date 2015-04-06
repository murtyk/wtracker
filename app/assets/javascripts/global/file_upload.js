function bind_jquery_file_upload(file_element, btn){
  file_element.fileupload({
    dataType: 'script',
    maxNumberOfFiles: 1,
    autoUpload: false,
    replaceFileInput:false,
    fileInput: $("input:file"),
    add: function (e, data) {
       btn.on('click',function () {
         data.submit();
       });
    }
  });
}