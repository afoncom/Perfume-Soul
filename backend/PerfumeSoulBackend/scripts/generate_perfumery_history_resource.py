#!/usr/bin/env python3
"""Build the backend's publication catalog from the editorial draft file."""

import datetime as dt
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
SOURCE = ROOT / 'docs/content/perfumery-history/stories.draft.json'
DESTINATION = (
    Path(__file__).resolve().parents[1]
    / 'Sources/PerfumeSoulBackend/Resources/perfumery-history.json'
)


def main() -> None:
    draft = json.loads(SOURCE.read_text(encoding='utf-8'))
    start = dt.date.fromisoformat(draft['publicationWindow']['startDate'])
    end = dt.date.fromisoformat(draft['publicationWindow']['endDate'])
    expected = draft['publicationWindow']['expectedStoryCount']
    entries = []
    for story in draft['stories']:
        publication = dt.date.fromisoformat(story['publicationDate'])
        event = dt.date.fromisoformat(story['eventDate'])
        assert story['status'] == 'draft'
        assert (publication.month, publication.day) == (event.month, event.day)
        entries.append({
            'dateKey': story['publicationDate'],
            'eventYear': event.year,
            'titleRu': story['localizations']['ru']['title'],
            'titleEn': story['localizations']['en']['title'],
            'fullStoryRu': story['localizations']['ru']['fullStory'],
            'fullStoryEn': story['localizations']['en']['fullStory'],
        })

    entries.sort(key=lambda item: item['dateKey'])
    actual_dates = [item['dateKey'] for item in entries]
    required_dates = [
        (start + dt.timedelta(days=offset)).isoformat()
        for offset in range((end - start).days + 1)
    ]
    assert len(entries) == expected == 731
    assert actual_dates == required_dates
    DESTINATION.parent.mkdir(parents=True, exist_ok=True)
    DESTINATION.write_text(
        json.dumps(entries, ensure_ascii=False, indent=2) + '\n',
        encoding='utf-8',
    )
    print(f'Generated {len(entries)} stories in {DESTINATION}')


if __name__ == '__main__':
    main()
