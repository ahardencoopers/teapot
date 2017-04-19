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
});
