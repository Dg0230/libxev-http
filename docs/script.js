// Navigation toggle for mobile
document.addEventListener('DOMContentLoaded', function() {
    const navToggle = document.querySelector('.nav-toggle');
    const navLinks = document.querySelector('.nav-links');

    if (navToggle && navLinks) {
        navToggle.addEventListener('click', function() {
            navLinks.classList.toggle('active');
            navToggle.classList.toggle('active');
        });
    }

    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                const headerHeight = document.querySelector('.header').offsetHeight;
                const targetPosition = target.offsetTop - headerHeight - 20;

                window.scrollTo({
                    top: targetPosition,
                    behavior: 'smooth'
                });
            }
        });
    });

    // Copy to clipboard functionality
    document.querySelectorAll('.copy-btn').forEach(button => {
        button.addEventListener('click', async function() {
            const textToCopy = this.getAttribute('data-copy');

            try {
                await navigator.clipboard.writeText(textToCopy);

                // Visual feedback
                const originalText = this.textContent;
                this.textContent = 'Copied!';
                this.style.background = 'rgba(16, 185, 129, 0.3)';

                setTimeout(() => {
                    this.textContent = originalText;
                    this.style.background = 'rgba(255, 255, 255, 0.1)';
                }, 2000);

            } catch (err) {
                console.error('Failed to copy text: ', err);

                // Fallback for older browsers
                const textArea = document.createElement('textarea');
                textArea.value = textToCopy;
                document.body.appendChild(textArea);
                textArea.select();
                document.execCommand('copy');
                document.body.removeChild(textArea);

                // Visual feedback
                const originalText = this.textContent;
                this.textContent = 'Copied!';
                this.style.background = 'rgba(16, 185, 129, 0.3)';

                setTimeout(() => {
                    this.textContent = originalText;
                    this.style.background = 'rgba(255, 255, 255, 0.1)';
                }, 2000);
            }
        });
    });

    // Header background on scroll
    const header = document.querySelector('.header');
    let lastScrollTop = 0;

    window.addEventListener('scroll', function() {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

        if (scrollTop > 100) {
            header.style.background = 'rgba(255, 255, 255, 0.98)';
            header.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
        } else {
            header.style.background = 'rgba(255, 255, 255, 0.95)';
            header.style.boxShadow = 'none';
        }

        lastScrollTop = scrollTop;
    });

    // Intersection Observer for animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);

    // Observe elements for animation
    document.querySelectorAll('.feature-card, .step, .performance-item').forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        el.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(el);
    });

    // Syntax highlighting for code blocks (simple)
    document.querySelectorAll('code').forEach(block => {
        let html = block.innerHTML;

        // Simple Zig syntax highlighting
        html = html.replace(/\b(const|var|fn|pub|try|defer|if|else|while|for|switch|struct|enum|union|error|anyerror|void|u8|u16|u32|u64|i8|i16|i32|i64|f32|f64|bool|usize|isize)\b/g, '<span style="color: #f59e0b;">$1</span>');
        html = html.replace(/\b(std|@import|@as|@intCast|@floatCast)\b/g, '<span style="color: #8b5cf6;">$1</span>');
        html = html.replace(/"([^"]*)"/g, '<span style="color: #10b981;">"$1"</span>');
        html = html.replace(/\/\/.*$/gm, '<span style="color: #6b7280;">$&</span>');
        html = html.replace(/\b(\d+)\b/g, '<span style="color: #f97316;">$1</span>');

        block.innerHTML = html;
    });

    // Add loading animation
    const loadingElements = document.querySelectorAll('.hero-code, .features-grid');
    loadingElements.forEach(el => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(30px)';
        el.style.transition = 'opacity 0.8s ease, transform 0.8s ease';

        setTimeout(() => {
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
        }, 300);
    });

    // Performance metrics animation (if we add them later)
    function animateCounter(element, target, duration = 2000) {
        let start = 0;
        const increment = target / (duration / 16);

        function updateCounter() {
            start += increment;
            if (start < target) {
                element.textContent = Math.floor(start);
                requestAnimationFrame(updateCounter);
            } else {
                element.textContent = target;
            }
        }

        updateCounter();
    }

    // Add performance counters if elements exist
    const performanceCounters = document.querySelectorAll('.performance-counter');
    performanceCounters.forEach(counter => {
        const target = parseInt(counter.getAttribute('data-target'));
        const observer = new IntersectionObserver(function(entries) {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    animateCounter(counter, target);
                    observer.unobserve(counter);
                }
            });
        });
        observer.observe(counter);
    });
});

// Add mobile navigation styles
const style = document.createElement('style');
style.textContent = `
    @media (max-width: 768px) {
        .nav-links {
            position: fixed;
            top: 100%;
            left: 0;
            right: 0;
            background: white;
            flex-direction: column;
            padding: 2rem;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            transform: translateY(-100%);
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }

        .nav-links.active {
            transform: translateY(0);
            opacity: 1;
            visibility: visible;
        }

        .nav-toggle.active span:nth-child(1) {
            transform: rotate(45deg) translate(5px, 5px);
        }

        .nav-toggle.active span:nth-child(2) {
            opacity: 0;
        }

        .nav-toggle.active span:nth-child(3) {
            transform: rotate(-45deg) translate(7px, -6px);
        }
    }
`;
document.head.appendChild(style);
