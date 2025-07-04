# Web Development Project Configuration

This Claude configuration is optimized for modern web development projects.

## Project Context

### Tech Stack
- **Frontend**: React 18+ with TypeScript
- **State Management**: Redux Toolkit / Zustand
- **Styling**: Tailwind CSS / CSS Modules
- **Build Tool**: Vite
- **Testing**: Jest, React Testing Library, Cypress
- **Backend**: Node.js with Express/Fastify
- **Database**: PostgreSQL with Prisma ORM
- **API**: RESTful with OpenAPI documentation

### Project Structure
```
src/
├── components/         # Reusable UI components
│   ├── common/        # Generic components
│   └── features/      # Feature-specific components
├── pages/             # Page components
├── hooks/             # Custom React hooks
├── services/          # API services
├── store/             # State management
├── utils/             # Utility functions
├── types/             # TypeScript types
└── styles/            # Global styles
```

## Development Standards

### Component Guidelines
```typescript
// Functional component with TypeScript
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  onClick: () => void;
  children: React.ReactNode;
  disabled?: boolean;
}

export const Button: React.FC<ButtonProps> = ({ 
  variant = 'primary',
  onClick,
  children,
  disabled = false
}) => {
  return (
    <button
      className={`btn btn-${variant}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
};
```

### State Management Pattern
```typescript
// Using Redux Toolkit slice
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface UserState {
  currentUser: User | null;
  isLoading: boolean;
  error: string | null;
}

const userSlice = createSlice({
  name: 'user',
  initialState: { currentUser: null, isLoading: false, error: null },
  reducers: {
    setUser: (state, action: PayloadAction<User>) => {
      state.currentUser = action.payload;
    },
    // ... other reducers
  },
});
```

### API Service Pattern
```typescript
// API service with error handling
class ApiService {
  private baseURL = process.env.VITE_API_URL;

  async request<T>(endpoint: string, options?: RequestInit): Promise<T> {
    try {
      const response = await fetch(`${this.baseURL}${endpoint}`, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...options?.headers,
        },
      });

      if (!response.ok) {
        throw new ApiError(response.status, await response.text());
      }

      return response.json();
    } catch (error) {
      this.handleError(error);
      throw error;
    }
  }
}
```

## Claude Instructions

### When Creating Components
1. Use functional components with TypeScript
2. Implement proper prop validation
3. Include JSDoc comments for complex props
4. Create accompanying test files
5. Use semantic HTML elements
6. Ensure accessibility (ARIA labels, keyboard navigation)
7. Implement responsive design
8. Memoize expensive computations

### When Working with State
1. Keep state as local as possible
2. Use proper TypeScript types for state
3. Implement loading and error states
4. Use optimistic updates where appropriate
5. Normalize complex state shapes
6. Avoid unnecessary re-renders

### API Integration
1. Always handle loading, success, and error states
2. Implement proper error boundaries
3. Use abort controllers for cleanup
4. Cache responses when appropriate
5. Validate API responses
6. Implement retry logic for failed requests

### Performance Optimization
1. Lazy load routes and heavy components
2. Implement virtual scrolling for long lists
3. Optimize images (WebP, lazy loading, srcset)
4. Use React.memo for expensive components
5. Debounce/throttle event handlers
6. Minimize bundle size
7. Implement code splitting

## Testing Requirements

### Unit Tests
```typescript
// Example component test
describe('Button', () => {
  it('renders with correct text', () => {
    render(<Button onClick={jest.fn()}>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    fireEvent.click(screen.getByText('Click me'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### Integration Tests
- Test user flows end-to-end
- Mock external services
- Test error scenarios
- Verify accessibility
- Test responsive behavior

## CSS/Styling Guidelines

### Tailwind CSS Conventions
```jsx
// Use consistent spacing and sizing
<div className="p-4 md:p-6 lg:p-8">
  <h1 className="text-2xl md:text-3xl font-bold text-gray-900 dark:text-white">
    Title
  </h1>
  <p className="mt-2 text-gray-600 dark:text-gray-300">
    Description
  </p>
</div>

// Extract repeated classes to components
const cardStyles = "rounded-lg shadow-md p-6 bg-white dark:bg-gray-800";
```

### Dark Mode Support
- Always include dark mode variants
- Use CSS variables for theme colors
- Test in both light and dark modes
- Ensure sufficient contrast ratios

## Accessibility Standards

### WCAG 2.1 AA Compliance
- Semantic HTML structure
- Proper heading hierarchy
- Keyboard navigation support
- Screen reader compatibility
- Color contrast ratios (4.5:1 minimum)
- Focus indicators
- Alt text for images
- ARIA labels where needed

### Common Patterns
```jsx
// Accessible form
<form onSubmit={handleSubmit}>
  <label htmlFor="email" className="block text-sm font-medium">
    Email Address
    <input
      id="email"
      type="email"
      required
      aria-describedby="email-error"
      className="mt-1 block w-full"
    />
  </label>
  {errors.email && (
    <p id="email-error" role="alert" className="text-red-600">
      {errors.email}
    </p>
  )}
</form>
```

## Security Considerations

### Frontend Security
- Sanitize user inputs
- Use Content Security Policy
- Implement HTTPS everywhere
- Secure authentication tokens
- Validate data on frontend AND backend
- Prevent XSS attacks
- Use secure cookies
- Implement rate limiting

### API Security
```typescript
// Secure API calls
const secureRequest = async (endpoint: string, options?: RequestInit) => {
  const token = await getAuthToken();
  
  return fetch(endpoint, {
    ...options,
    headers: {
      ...options?.headers,
      'Authorization': `Bearer ${token}`,
      'X-CSRF-Token': getCsrfToken(),
    },
    credentials: 'include',
  });
};
```

## Performance Metrics

### Core Web Vitals Targets
- **LCP** (Largest Contentful Paint): < 2.5s
- **FID** (First Input Delay): < 100ms
- **CLS** (Cumulative Layout Shift): < 0.1
- **TTFB** (Time to First Byte): < 600ms

### Monitoring
- Set up performance budgets
- Track real user metrics
- Monitor error rates
- Track API response times
- Analyze bundle sizes

## Development Workflow

### Code Quality Checks
1. ESLint must pass
2. TypeScript must compile without errors
3. All tests must pass
4. No console.logs in production code
5. No commented-out code
6. Lighthouse score > 90

### Pre-commit Checks
```json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm test"
    }
  },
  "lint-staged": {
    "*.{ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{css,scss}": ["stylelint --fix", "prettier --write"]
  }
}
```

---

*This configuration is optimized for modern web development. Adjust based on your specific project needs.*