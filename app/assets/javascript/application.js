document.addEventListener('DOMContentLoaded', function() {
    if (localStorage.getItem('scrollToTop') === 'true') {
        window.scrollTo({ top: 0, behavior: 'smooth' });
        localStorage.removeItem('scrollToTop');
    }
});
