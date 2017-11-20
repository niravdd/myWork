function nextLab(page) {
	window.location.href = + page +'.html';
	}

function reveal(button, content) {
	if (document.getElementById(content).className == 'indent-show') {
	document.getElementById(content).className = 'indent-hide';
} else {
	document.getElementById(content).className = 'indent-show';
}
}

function changetext() {
	document.getElementById("keypair").innerHTML = document.getElementById("keypair").innerHTML.replace(/\%KEYPAIR\%/g,document.getElementById("keypairinput").value);
	document.getElementById("iam-fh-policy").innerHTML = document.getElementById("iam-fh-policy").innerHTML.replace(/\%ACCOUNTID\%/g,document.getElementById("accountidinput").value);
	document.getElementById("analyticsInput").innerHTML = document.getElementById("analyticsInput").innerHTML.replace(/\%ACCOUNTID\%/g,document.getElementById("accountidinput").value);
	document.getElementById("telemetryInput").innerHTML = document.getElementById("telemetryInput").innerHTML.replace(/\%ACCOUNTID\%/g,document.getElementById("accountidinput").value);
	document.getElementById("fh-streams").innerHTML = document.getElementById("fh-streams").innerHTML.replace(/\%ACCOUNTID\%/g,document.getElementById("accountidinput").value);
}

function changeredshifttext() {
	document.getElementById("analyticsInput").innerHTML = document.getElementById("analyticsInput").innerHTML.replace(/\%REDSHIFTCLUSTER\%/g,document.getElementById("redshiftinput").value);
	document.getElementById("telemetryInput").innerHTML = document.getElementById("telemetryInput").innerHTML.replace(/\%REDSHIFTCLUSTER\%/g,document.getElementById("redshiftinput").value);
}