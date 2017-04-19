$(document).ready(() => {
	$.ajax({
		url: '/request',
		type: 'POST',
		contentType: 'application/x-www-form-urlencoded',
		dataType: 'json',
		data: {
			action: 'get_recently_added_videos'
		},
		success: (res) => {
			$('#video-wrapper').html(res.html);
		},
		error: () => {
			alert('Something went wrong, try again later...');
		}
	});
});
