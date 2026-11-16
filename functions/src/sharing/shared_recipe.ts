import { invalid, maxTitleLength, requireFits } from './requests.js';

/** A titled list of lines, such as an ingredient section or step section. */
export interface SharedSection {
  readonly title: string | null;
  readonly items: readonly string[];
}

/**
 * The read-only form of a recipe on a view-only link page. The app renders
 * amounts and units into plain text, so the page needs no unit logic.
 */
export interface SharedRecipe {
  readonly title: string;
  readonly yield: string | null;
  readonly sourceName: string | null;
  readonly sourceUrl: string | null;
  readonly ingredients: readonly SharedSection[];
  readonly steps: readonly SharedSection[];
}

/** The longest single ingredient line or step. */
const maxLineLength = 5000;

const string = (value: unknown, field: string, maxLength: number): string => {
  if (typeof value !== 'string' || value.length > maxLength) {
    throw invalid(`Expected ${field} to be a string`);
  }
  return value;
};

const nullableString = (
  value: unknown,
  field: string,
  maxLength: number,
): string | null =>
  value === null || value === undefined
    ? null
    : string(value, field, maxLength);

const sections = (value: unknown, field: string): SharedSection[] => {
  if (!Array.isArray(value)) {
    throw invalid(`Expected ${field} to be a list`);
  }
  return value.map((section: unknown) => {
    if (typeof section !== 'object' || section === null) {
      throw invalid(`Expected ${field} to hold sections`);
    }
    const { title, items } = section as Record<string, unknown>;
    if (!Array.isArray(items)) {
      throw invalid(`Expected ${field} items to be a list`);
    }
    return {
      title: nullableString(title, `${field} title`, maxTitleLength),
      items: items.map((item) => string(item, `${field} item`, maxLineLength)),
    };
  });
};

const sourceUrl = (value: unknown): string | null => {
  const url = nullableString(value, 'sourceUrl', 2000);
  if (url === null) {
    return null;
  }
  const protocol = URL.parse(url)?.protocol;
  if (protocol !== 'https:' && protocol !== 'http:') {
    throw invalid('Expected sourceUrl to be a web address');
  }
  return url;
};

/** Reads and checks a [SharedRecipe] sent by the app. */
export const parseSharedRecipe = (value: unknown): SharedRecipe => {
  if (typeof value !== 'object' || value === null) {
    throw invalid('Expected recipe to be an object');
  }
  requireFits(value, 'recipe');
  const recipe = value as Record<string, unknown>;
  const title = string(recipe.title, 'title', maxTitleLength).trim();
  if (title === '') {
    throw invalid('Expected a title');
  }
  return {
    title,
    yield: nullableString(recipe.yield, 'yield', maxTitleLength),
    sourceName: nullableString(recipe.sourceName, 'sourceName', maxTitleLength),
    sourceUrl: sourceUrl(recipe.sourceUrl),
    ingredients: sections(recipe.ingredients, 'ingredients'),
    steps: sections(recipe.steps, 'steps'),
  };
};
