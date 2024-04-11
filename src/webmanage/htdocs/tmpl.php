<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<style type="text/css">
.info_area{
	color:red;
	margin-top:5px;
	margin-bottom:5px;
}
#output_div{
	border:solid 1px rgb(169, 169, 169);
	color:rgb(169, 169, 169);
	width:1600px;
	height:700px;
	text-align:left;
	overflow-y:scroll;
}
</style>
</head>
<body>
<div style="text-align:center">
<table style="margin-left:auto;margin-right:auto">
<tr><td><button id="start_build" style="height:50px;width:100px">构建开发环境</button>&nbsp;&nbsp;&nbsp;<button id="sync_46" style="height:50px;width:100px">同步测试环境</button>&nbsp;&nbsp;&nbsp;<button id="restart_46" style="height:50px;width:100px">重启测试环境</button></td></tr>
<!--<tr><td><textarea rows="50" cols="250" id="output_div"></textarea></td></tr> -->
<tr><td><div id="output_div"></div></td></tr>
</table>
</div>
<script type="text/javascript" src="./lib/jquery.js"></script>
<script type="text/javascript">

var g_build_type = "build_dev";
var g_content = '';

$("#start_build").click(onStartBuild);
$("#sync_46").click(onSync46);
$("#restart_46").click(onRestart46);

function onStartBuild(){
	g_content = '';
	g_build_type = "build_dev";
	var url = "http://"+window.location.hostname+"/start_build.php";
	$.ajax({
  type: "POST",
  url: url,
  data: {},
  success: function(ret){
	  $('#start_build,#sync_46,#restart_46').attr('disabled','disabled');
	  $("#output_div").val("开始构建，请稍后");
	onGetMakeInfo();
  }
});
}

function onSync46(){
	g_content = '';
	g_build_type = "sync_test";
	var url = "http://"+window.location.hostname+"/sync_46.php";
	$.ajax({
  type: "POST",
  url: url,
  data: {},
  success: function(ret){
	  $('#start_build,#sync_46,#restart_46').attr('disabled','disabled');
	  $("#output_div").val("开始同步，请稍后");
	onGetMakeInfo();
  }
});
}

function onRestart46(){
	g_content = '';
	g_build_type = "restart_test";
	var url = "http://"+window.location.hostname+"/restart_46.php";
	$.ajax({
  type: "POST",
  url: url,
  data: {},
  success: function(ret){
	  $('#start_build,#sync_46,#restart_46').attr('disabled','disabled');
	  $("#output_div").val("开始重启，请稍后");
	onGetMakeInfo();
  }
});
}



var g_make_info_offset = 0;
function onGetMakeInfo(){
	var url = "http://"+window.location.hostname+"/getmakeinfo.php";
	$.ajax({
  type: "POST",
  url: url,
  data: {build_type:g_build_type, read_offset:g_make_info_offset},
  success: function(data){
		onGetMakeDataInfo(data);
	},
   error:function(data){
	   $("#output_div").val("发生错误");
	   onEndBuild();
   }
	});
}

function getContentHtml(content){
	html = content.replace(/\n/g,'<br>').replace(/\s/g,'&nbsp;').replace(/__info_start__/g,'<div class="info_area">').replace(/__info_end__[\n]?/g,'</div>');
	html = html.replace(/<br><div/g,'<div').replace(/(<br>){2,}/g,'<br>').replace(/<\/div><br>/g,'</div>');
	return html;
}
function onGetMakeDataInfo(data){
	var arr_data = data.split("\n");
	var ret     = parseInt(arr_data[0]);
	var errmsg  = arr_data[1];
	var cur_pos = parseInt(arr_data[2]);
	if (ret != 0){
		setTimeout(onGetMakeInfo, 1000);
		return;
	}
	if (typeof cur_pos == "undefined"){
		$("#output_div").val("发生错误");
	   onEndBuild();
	   return;
	}
	g_make_info_offset = cur_pos;
	var end_magic = /__________end_magic_____________/;
	var is_end = false;

	var content_data = [];
	for (var i = 3; i < arr_data.length; i++){
		if (arr_data[i].match(end_magic)){
			is_end = true;
		}
		else{
			content_data.push(arr_data[i]);
		}
	}
	var content = content_data.join("\n");
	g_content = content;
	content = content.replace(/[\n]{2,}/g,"\n");
	if (content == "\n"){
		content = "";
	}
	if (content != ""){
		var text = $("#output_div").html();
		if (text.length > 100*1024){
			text = "";
		}
		var html = getContentHtml(g_content);
		$("#output_div").html(html);
		$('#output_div').scrollTop($('#output_div')[0].scrollHeight);
	}
	if (is_end){
		onEndBuild();
	}
	else{
		if (content != ""){
			setTimeout(onGetMakeInfo, 100);
		}
		else{
			setTimeout(onGetMakeInfo, 1000);
		}
	}
}


function onEndBuild(){
	 $('#start_build,#sync_46,#restart_46').removeAttr('disabled');
	 g_make_info_offset = 0;
}
</script>
</body>
</html>