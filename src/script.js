// Smooth scrolling for navigation links
document.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', (e) => {
        e.preventDefault();
        const targetId = link.getAttribute('href');
        const targetSection = document.querySelector(targetId);
        
        targetSection.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
        });
    });
});

// Parallax effect for hero section
window.addEventListener('scroll', () => {
    const scrolled = window.pageYOffset;
    const parallax = document.querySelector('.hero-3d-element');
    
    if (parallax) {
        parallax.style.transform = `translateY(${scrolled * 0.5}px)`;
    }
});

// Animated counter for community stats
const animateCounters = () => {
    const counters = document.querySelectorAll('.stat-value');
    
    counters.forEach(counter => {
        const target = parseInt(counter.getAttribute('data-target'));
        const increment = target / 100;
        let current = 0;
        
        const updateCounter = () => {
            if (current < target) {
                current += increment;
                counter.textContent = Math.ceil(current);
                requestAnimationFrame(updateCounter);
            } else {
                counter.textContent = target;
            }
        };
        
        updateCounter();
    });
};

// Intersection Observer for animations
const observerOptions = {
    threshold: 0.2,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            if (entry.target.classList.contains('community-stats')) {
                animateCounters();
            }
            entry.target.classList.add('animated');
        }
    });
}, observerOptions);

// Observe elements for animation
document.querySelectorAll('.card-3d, .project-card, .stat-card').forEach(card => {
    observer.observe(card);
});

const communityStats = document.querySelector('.community-stats');
if (communityStats) {
    observer.observe(communityStats);
}

// Interactive 3D cube mouse tracking
const cube = document.querySelector('.cube');
let mouseX = 0;
let mouseY = 0;
let currentX = 0;
let currentY = 0;

document.addEventListener('mousemove', (e) => {
    mouseX = (e.clientX / window.innerWidth - 0.5) * 50;
    mouseY = (e.clientY / window.innerHeight - 0.5) * 50;
});

const animateCube = () => {
    currentX += (mouseX - currentX) * 0.05;
    currentY += (mouseY - currentY) * 0.05;
    
    if (cube) {
        cube.style.transform = `rotateX(${-currentY}deg) rotateY(${currentX}deg)`;
    }
    
    requestAnimationFrame(animateCube);
};

animateCube();

// Form submission
const contactForm = document.querySelector('.contact-form');
if (contactForm) {
    contactForm.addEventListener('submit', (e) => {
        e.preventDefault();
        
        // Add submission animation
        const button = contactForm.querySelector('.submit-button');
        button.innerHTML = '<span>Sending...</span><div class="button-bg"></div>';
        
        // Simulate form submission
        setTimeout(() => {
            button.innerHTML = '<span>Message Sent!</span><div class="button-bg"></div>';
            contactForm.reset();
            
            setTimeout(() => {
                button.innerHTML = '<span>Send Message</span><div class="button-bg"></div>';
            }, 2000);
        }, 1500);
    });
}

// Dynamic particle background
const createParticle = () => {
    const particle = document.createElement('div');
    particle.className = 'particle';
    
    const size = Math.random() * 5 + 1;
    const duration = Math.random() * 20 + 10;
    const delay = Math.random() * 5;
    const startX = Math.random() * window.innerWidth;
    
    particle.style.cssText = `
        position: fixed;
        width: ${size}px;
        height: ${size}px;
        background: var(--primary-color);
        border-radius: 50%;
        left: ${startX}px;
        bottom: -10px;
        opacity: 0.5;
        animation: rise ${duration}s linear ${delay}s infinite;
        pointer-events: none;
        z-index: -1;
    `;
    
    document.body.appendChild(particle);
    
    setTimeout(() => {
        particle.remove();
    }, (duration + delay) * 1000);
};

// Create particles periodically
setInterval(createParticle, 500);

// Add CSS for particle animation
const style = document.createElement('style');
style.textContent = `
    @keyframes rise {
        0% {
            transform: translateY(0) translateX(0);
            opacity: 0.5;
        }
        50% {
            transform: translateY(-50vh) translateX(50px);
            opacity: 0.8;
        }
        100% {
            transform: translateY(-100vh) translateX(-50px);
            opacity: 0;
        }
    }
    
    .animated {
        animation: fadeInUp 0.8s ease-out;
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
`;
document.head.appendChild(style);

// Navigation background on scroll
window.addEventListener('scroll', () => {
    const nav = document.querySelector('.nav-3d');
    if (window.scrollY > 100) {
        nav.style.background = 'rgba(10, 10, 10, 0.95)';
    } else {
        nav.style.background = 'rgba(10, 10, 10, 0.9)';
    }
});

// Add hover effects to tech planets
document.querySelectorAll('.tech-planet').forEach(planet => {
    planet.addEventListener('mouseenter', () => {
        planet.style.background = 'var(--primary-color)';
        planet.style.color = 'var(--bg-dark)';
        planet.style.boxShadow = '0 0 20px var(--primary-color)';
    });
    
    planet.addEventListener('mouseleave', () => {
        planet.style.background = 'var(--bg-medium)';
        planet.style.color = 'var(--text-primary)';
        planet.style.boxShadow = 'none';
    });
});

// Initialize page
document.addEventListener('DOMContentLoaded', () => {
    console.log('LoRa WiFi Community site initialized');
    
    // Add loading animation
    document.body.style.opacity = '0';
    setTimeout(() => {
        document.body.style.transition = 'opacity 1s ease';
        document.body.style.opacity = '1';
    }, 100);
});