$(document).ready(() => {
	$('#sign-up').on('click', () => {
		if(
			$($('input')[0]).val() == '' ||
			$($('input')[1]).val() == '' ||
			$($('input')[2]).val() == '' ||
			($($('input')[1]).val() !== $($('input')[2]).val())
		) {
			alert('Please enter all fields');
		}
		else {
			$.ajax({
				url: 'request',
				type: 'POST',
				data: {
					action: 'register',
					username: $($('input')[0]).val(),
					password: $($('input')[1]).val()
				},
				dataType: 'json',
				contentType: 'application/x-www-form-urlencoded',
				success: (result) => {
					window.location.replace('/home');
				},
				error: (errorMessage) => {
					alert('Something went wrong, try again later...');
				}
			});
		}
	});
});
