function help(seat) {
	document.getElementById("help_message").innerHTML = '<a href="javascript:void();">Sending request...</a>';
	// Initialize the Amazon Cognito credentials provider
	AWS.config.region = 'us-west-2'; // Region
	AWS.config.credentials = new AWS.CognitoIdentityCredentials({
		IdentityPoolId: 'us-west-2:b41e82e7-43db-4d15-9509-de05d39f00ff',
	});

	var url = new URL(window.location.href);
	var seat_num = url.searchParams.get("seat");

	if (isNaN(seat_num) || seat_num < 1 || seat_num > 120 ) {
		document.getElementById("help_message").innerHTML = '<a href="javascript:void();">Very funny - Please don\'t try to break the lab!</a>';
	} else {

		var input = {
			seat: seat_num
		};

		var lambda = new AWS.Lambda();
		lambda.invoke({
			FunctionName: 'gam310WorkshopHelp',
			Payload: JSON.stringify(input)
		}, function (err, data) {
			if (err) {
				console.log(err, err.stack);
				document.getElementById("help_message").innerHTML = '<a href="javascript:void();">There was a problem sending your request</a>';
			} else {
				console.log(JSON.parse(data.Payload));
				document.getElementById("help_message").innerHTML = '<a href="javascript:void();">Your request has been sent</a>';
			}
		})

		setTimeout(function() {
			document.getElementById("help_message").innerHTML = '<a href="javascript:void();">&nbsp;</a>';
		}, 10000);
	}
}

function nextLab(page, lab_num) {
	var url = new URL(window.location.href);
	if (isNaN(url.searchParams.get("seat")) || url.searchParams.get("seat") < 1 || url.searchParams.get("seat") > 120 ) {
		document.getElementById("message").innerHTML = '<a href="javascript:void();">Very funny - Please don\'t try to break the lab!</a>';
	} else {
		// Initialize the Amazon Cognito credentials provider
		AWS.config.region = 'us-west-2'; // Region
		AWS.config.credentials = new AWS.CognitoIdentityCredentials({
			IdentityPoolId: 'us-west-2:b41e82e7-43db-4d15-9509-de05d39f00ff',
		});

		var input = {
			seat: url.searchParams.get("seat"),
			lab: lab_num
		}

		var lambda = new AWS.Lambda();
		lambda.invoke({
			FunctionName: 'gam310WorkshopUpdate',
			Payload: JSON.stringify(input)
		}, function (err, data) {
			if (err) {
				console.log(err, err.stack);
				document.getElementById("message").innerHTML = 'There was a problem registering your progress in the backend database - please try again.';
				setTimeout(function() {
					document.getElementById("message").innerHTML = '&nbsp;';
				}, 5000);
			} else {
				window.location.href = '/' + page +'.html?seat=' + url.searchParams.get("seat");
			}
		})
	}
}

// function nextLab(page) {
// 	window.location.href = + page +'.html';
// 	}

function reveal(button, content) {
	if (document.getElementById(content).className == 'indent-show') {
	document.getElementById(content).className = 'indent-hide';
} else {
	document.getElementById(content).className = 'indent-show';
}
}

function changetext() {
	document.getElementById("cfn").innerHTML = document.getElementById("cfn").innerHTML.replace(/\${keypair}/g,document.getElementById("keypairinput").value);
	document.getElementById("fh-streams").innerHTML = document.getElementById("fh-streams").innerHTML.replace(/\${accountid}/g,document.getElementById("accountidinput").value);
	document.getElementById("cleanup").innerHTML = document.getElementById("cleanup").innerHTML.replace(/\${accountid}/g,document.getElementById("accountidinput").value);
}

function changeredshifttext() {
	document.getElementById("code6").innerHTML = document.getElementById("code6").innerHTML.replace(/\redshiftClusterEndpoint/g,document.getElementById("redshiftinput").value);
}