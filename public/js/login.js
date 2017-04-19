$(document).ready(() => {
	$('#login').on('click', () => {
		if(
			$($('input')[0]).val() == '' ||
			$($('input')[1]).val() == ''
		) {
			alert('Please enter all fields');
		}
		else {
			$.ajax({
				url: 'request',
				type: 'POST',
				data: {
					action: 'login',
					username: $($('input')[0]).val(),
					password: $($('input')[1]).val()
				},
				dataType: 'json',
				contentType: 'application/x-www-form-urlencoded',
				success: (res) => {
					window.location.replace('/home');
				},
				error: (errorMessage) => {
					alert('Something went wrong, try again later');
				}
			});
		}
	});
});
