# BDD Writing Guide

Write feature files as living documentation and keep them strictly coupled to the
tests. A `.feature` file is business-readable specification first, and a test
input second.

## Feature Files

- One `Feature:` per file. State the business capability, not the UI.
- Give the feature a one-line intent, optionally with the connextra form
  ("As a ... I want ... so that ...") when it adds value.
- Keep each `Scenario:` focused on a single behaviour with one clear outcome.
- Write steps declaratively: describe *what* the system does, not *how* the user
  clicks. Prefer "When the user submits an invalid password" over "When the user
  types 'x' and presses the submit button".
- Use `Background:` for shared `Given` context and `Scenario Outline:` with
  `Examples:` for the same behaviour across data variations.
- Keep domain vocabulary consistent with the project glossary and ubiquitous
  language (see `../domain-modeling/SKILL.md`).

## Scenario-to-Test Naming

The test name MUST be a direct, sanitized translation of the scenario title so a
reviewer can trace documentation to code by name alone.

Normalize the scenario title into an identifier:

1. Lowercase the title (keep original casing only where the language convention
   demands CamelCase or PascalCase).
2. Transliterate accented and special characters to ASCII: `ä→ae`, `ö→oe`,
   `ü→ue`, `ß→ss`, `é→e`. Keep it readable, not lossy.
3. Replace runs of whitespace and punctuation with a single separator
   (`_` for snake_case, or word boundaries for CamelCase).
4. Trim leading and trailing separators.

Examples:

| Scenario title            | snake_case                | CamelCase                |
|---------------------------|---------------------------|--------------------------|
| Passwort ist zu kurz      | `passwort_ist_zu_kurz`    | `PasswortIstZuKurz`      |
| Password is too short     | `password_is_too_short`   | `PasswordIsTooShort`     |
| Cart total includes VAT   | `cart_total_includes_vat` | `CartTotalIncludesVat`   |

Apply the language's usual test-name prefix (for example `test_...` in Python,
`Test...` in Go, `should_...` where the project already does so). Keep one test
per scenario.

## Given / When / Then Anchors

In classic unit tests, mark the three phases as comments so the structure maps to
Arrange, Act, and Assert. Keep the phases in order and do not interleave them.

### Python (pytest, classic)

```python
def test_passwort_ist_zu_kurz():
    # Given: a registration form with the minimum length policy
    form = RegistrationForm(min_password_length=8)

    # When: the user submits a password that is too short
    result = form.submit(password="short")

    # Then: registration is rejected with a length error
    assert result.rejected
    assert result.error == "password_too_short"
```

### Ruby (Minitest)

```ruby
def test_passwort_ist_zu_kurz
  # Given: a registration form with the minimum length policy
  form = RegistrationForm.new(min_password_length: 8)

  # When: the user submits a password that is too short
  result = form.submit(password: "short")

  # Then: registration is rejected with a length error
  assert result.rejected?
  assert_equal "password_too_short", result.error
end
```

### C# (xUnit)

```csharp
[Fact]
public void PasswortIstZuKurz()
{
    // Given: a registration form with the minimum length policy
    var form = new RegistrationForm(minPasswordLength: 8);

    // When: the user submits a password that is too short
    var result = form.Submit(password: "short");

    // Then: registration is rejected with a length error
    Assert.True(result.Rejected);
    Assert.Equal("password_too_short", result.Error);
}
```

## Native BDD Runners

When the project uses a native runner (pytest-bdd, behave, Cucumber), the
scenario title and its `Given`/`When`/`Then` steps live in the `.feature` file
and are executed through step definitions. In that case:

- Do not duplicate the steps as comments; the feature file is the source of
  truth.
- Keep step definitions thin — delegate to production code and test helpers.
- Still keep the strict one-scenario-to-one-behaviour discipline.

## Keeping Documentation and Code in Sync

- Every scenario has exactly one corresponding test; every behaviour test traces
  to a scenario.
- When behaviour changes, update the `.feature` file first, then the test.
- Do not weaken an assertion to make a test pass; a failing test is valid
  feedback about the specification or the implementation.
