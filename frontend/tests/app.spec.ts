import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('/');

  // Expect a title "to contain" a substring.
  await expect(page).toHaveTitle(/Book Shelf/);
});

test('should edit a book', async ({ page }) => {
  const initialBook = {
    id: '1',
    title: 'The Lord of the Rings',
    author: 'J.R.R. Tolkien',
    description: 'A fantasy novel.',
    coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51EstVXM1UL._SX331_BO1,204,203,200_.jpg'
  };
  const updatedTitle = 'The Hobbit';

  await page.route('**/book', async (route) => {
    if (route.request().method() === 'GET') {
      await route.fulfill({ json: [initialBook] });
    }
  });

  await page.route(`**/book/${initialBook.id}`, async (route) => {
    if (route.request().method() === 'GET') {
      await route.fulfill({ json: initialBook });
    } else if (route.request().method() === 'PUT') {
      await route.fulfill({ status: 200 });
    }
  });

  await page.goto('/');

  await page.click(`.book-card[data-id="${initialBook.id}"] .edit-btn`);

  await page.fill('#editTitle', updatedTitle);
  await page.click('#editBookForm button[type="submit"]');

  await page.route('**/book', async (route) => {
    if (route.request().method() === 'GET') {
      await route.fulfill({ json: [{ ...initialBook, title: updatedTitle }] });
    }
  });

  await page.waitForResponse('**/book');

  await expect(page.locator(`.book-card[data-id="${initialBook.id}"] .card-title`)).toHaveText(updatedTitle);
});

test('should delete a book', async ({ page }) => {
  const initialBook = {
    id: '1',
    title: 'The Lord of the Rings',
    author: 'J.R.R. Tolkien',
    description: 'A fantasy novel.',
    coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/I/51EstVXM1UL._SX331_BO1,204,203,200_.jpg'
  };

  await page.route('**/book', async (route) => {
    if (route.request().method() === 'GET') {
      await route.fulfill({ json: [initialBook] });
    }
  });

  await page.route(`**/book/${initialBook.id}`, async (route) => {
    if (route.request().method() === 'DELETE') {
      await route.fulfill({ status: 200 });
    }
  });

  await page.goto('/');

  await page.click(`.book-card[data-id="${initialBook.id}"] .delete-btn`);

  await page.route('**/book', async (route) => {
    if (route.request().method() === 'GET') {
      await route.fulfill({ json: [] });
    }
  });

  await page.waitForResponse('**/book');

  await expect(page.locator(`.book-card[data-id="${initialBook.id}"]`)).not.toBeVisible();
});
