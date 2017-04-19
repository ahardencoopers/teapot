$(document).ready(() => {
	$.ajax({
		url: '/request',
		type: 'POST',
		dataType: 'json',
		data: {
			action: 'load-home',
		},
		success: (res) => {
			$('#username-wrapper').html(res.username);
		},
		error: () => {
			alert('Something went wrong, try again later...');
		}
	});

	$('#delete-account-btn').on('click', () => {
		$.ajax({
			url: '/request',
			type: 'POST',
			contentType: 'application/x-www-form-urlencoded',
			dataType: 'json',
			data: {
				action: 'delete_account',
				password: $('#delete-account-bar').val()
			},
			success: (res) => {
				alert('Account successfully deleted');
				window.location.replace('/');
			},
			error: () => {
				alert('Something went wrong, try again later...');
			}
		});
	});
});
