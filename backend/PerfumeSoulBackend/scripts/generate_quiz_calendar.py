#!/usr/bin/env python3
"""Build two immutable 365-day quiz cycles using only the Python standard library."""

import collections
import datetime as dt
import json
from pathlib import Path
import random

RESOURCES = Path(__file__).resolve().parents[1] / "Sources/PerfumeSoulBackend/Resources"
START = dt.date(2026, 12, 1)


class Flow:
    def __init__(self):
        self.edges = collections.defaultdict(list)

    def add(self, source, target, capacity):
        forward = [target, capacity, None]
        backward = [source, 0, forward]
        forward[2] = backward
        self.edges[source].append(forward)
        self.edges[target].append(backward)
        return forward

    def run(self, source, sink):
        total = 0
        while True:
            levels = {source: 0}
            queue = collections.deque([source])
            while queue:
                node = queue.popleft()
                for target, capacity, _ in self.edges[node]:
                    if capacity and target not in levels:
                        levels[target] = levels[node] + 1
                        queue.append(target)
            if sink not in levels:
                return total
            positions = collections.defaultdict(int)

            def send(node, amount):
                if node == sink:
                    return amount
                edges = self.edges[node]
                while positions[node] < len(edges):
                    edge = edges[positions[node]]
                    target, capacity, reverse = edge
                    if capacity and levels.get(target) == levels[node] + 1:
                        sent = send(target, min(amount, capacity))
                        if sent:
                            edge[1] -= sent
                            reverse[1] += sent
                            return sent
                    positions[node] += 1
                return 0

            while sent := send(source, 5475):
                total += sent


def generate_cycle(questions, previous, seed):
    """Allocate difficulty quotas by flow; share a three-question topic/day limit."""
    previous_days = {qid: day for day, ids in enumerate(previous) for qid in ids}
    banned = {qid for ids in previous[-30:] for qid in ids}
    # These quotas exactly match the actual 3,559 / 1,642 / 274 bank counts.
    quotas = [(10, 5, 0)] * 91 + [(10, 4, 1)] * 183 + [(9, 5, 1)] * 91
    for attempt in range(100):
        rng = random.Random(seed + attempt)
        rng.shuffle(quotas)
        days = [[] for _ in range(365)]
        counts = [collections.Counter() for _ in days]
        for difficulty, quota_index in [("hard", 2), ("medium", 1), ("easy", 0)]:
            groups = collections.defaultdict(list)
            for question in questions:
                if question["difficulty"] == difficulty:
                    groups[(question["topic"], question["id"] in banned)].append(question)
            graph = Flow()
            allocations = []
            group_keys = list(groups)
            rng.shuffle(group_keys)
            day_order = list(range(365))
            rng.shuffle(day_order)
            for index, key in enumerate(group_keys):
                topic, delayed = key
                group = ("group", index)
                graph.add("source", group, len(groups[key]))
                for day in day_order:
                    if delayed and day < 30:
                        continue
                    target = ("topic", topic, day)
                    edge = graph.add(group, target, 3)
                    allocations.append((key, day, edge))
            for topic in sorted({key[0] for key in groups}):
                for day in range(365):
                    graph.add(("topic", topic, day), ("day", day), 3 - counts[day][topic])
            for day, quota in enumerate(quotas):
                graph.add(("day", day), "sink", quota[quota_index])
            if graph.run("source", "sink") != sum(len(group) for group in groups.values()):
                break
            for group in groups.values():
                rng.shuffle(group)
                # On later cycles prefer questions (and thus their topics) shown longest ago.
                group.sort(key=lambda question: previous_days.get(question["id"], 0))
                group.reverse()
            for key, day, edge in sorted(allocations, key=lambda item: item[1]):
                for _ in range(edge[2][1]):
                    question = groups[key].pop()
                    days[day].append(question)
                    counts[day][question["topic"]] += 1
        else:
            result = []
            for day in days:
                rng.shuffle(day)
                hard = [question for question in day if question["difficulty"] == "hard"]
                remaining = [question for question in day if question["difficulty"] != "hard"]
                ordered = []
                while remaining:
                    topic_counts = collections.Counter(question["topic"] for question in remaining)
                    choices = [question for question in remaining
                               if not ordered or question["topic"] != ordered[-1]["topic"]]
                    # Reserve a different final topic before the hard question.
                    if len(remaining) == 2 and hard:
                        choices = [question for question in choices
                                   if any(other is not question and other["topic"] != hard[0]["topic"]
                                          for other in remaining)] or choices
                    question = max(choices, key=lambda item: topic_counts[item["topic"]])
                    ordered.append(question)
                    remaining.remove(question)
                result.append([question["id"] for question in ordered + hard])
            return result
    raise ValueError("Cannot satisfy the calendar constraints for this bank")


def validate(questions, cycles):
    by_id = {question["id"]: question for question in questions}
    for cycle_index, days in enumerate(cycles):
        assert len(days) == 365
        assert collections.Counter(qid for day in days for qid in day) == collections.Counter(by_id.keys())
        for ids in days:
            assert len(ids) == 15
            entries = [by_id[qid] for qid in ids]
            topics = collections.Counter(entry["topic"] for entry in entries)
            difficulties = collections.Counter(entry["difficulty"] for entry in entries)
            assert len(topics) >= 5 and max(topics.values()) <= 3
            assert 9 <= difficulties["easy"] <= 10
            assert 4 <= difficulties["medium"] <= 5
            assert difficulties["hard"] <= 1
            assert not any(entry["difficulty"] == "hard" for entry in entries[:12])
            assert all(a["topic"] != b["topic"] for a, b in zip(entries, entries[1:]))
        if cycle_index:
            last_month = {qid for day in cycles[cycle_index - 1][-30:] for qid in day}
            assert not last_month.intersection(qid for day in days[:30] for qid in day)


def main():
    questions = json.loads((RESOURCES / "quiz-bank.json").read_text())["questions"]
    cycles = []
    for index in range(2):
        cycles.append(generate_cycle(questions, cycles[-1] if cycles else [], 20261201 + index * 1000))
    validate(questions, cycles)
    sets = [{"dayKey": (START + dt.timedelta(days=offset)).isoformat(), "questionIDs": ids}
            for offset, ids in enumerate(day for cycle in cycles for day in cycle)]
    output = RESOURCES / "quiz-calendar.json"
    payload = {"schemaVersion": 1, "days": sets}
    # Published dates must never be silently reassigned when extending the resource.
    if output.exists():
        old_days = json.loads(output.read_text())["days"]
        assert sets[:len(old_days)] == old_days, "Refusing to change published quiz dates"
    output.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n")
    print(f"Validated {len(sets)} dates, two complete cycles and the 30-day boundary exclusion")


if __name__ == "__main__":
    main()
