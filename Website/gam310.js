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
	document.getElementById("fh-streams").innerHTML = document.getElementById("fh-streams").innerHTML.replace(/\${accountid}/g,document.getElementById("accountidinput").value);
	document.getElementById("cleanup").innerHTML = document.getElementById("cleanup").innerHTML.replace(/\${accountid}/g,document.getElementById("accountidinput").value);
}

function changeredshifttext() {
	document.getElementById("redshifttables").innerHTML = document.getElementById("redshifttables").innerHTML.replace(/\%REDSHIFTCLUSTER\%/g,document.getElementById("redshiftinput").value);
}