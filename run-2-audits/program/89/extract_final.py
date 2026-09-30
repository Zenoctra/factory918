import json, sys
path, out = sys.argv[1], sys.argv[2]
last = None
with open(path) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            obj = json.loads(line)
        except Exception:
            continue
        if obj.get("type") != "assistant":
            continue
        msg = obj.get("message", {})
        content = msg.get("content", [])
        texts = [c.get("text", "") for c in content if isinstance(c, dict) and c.get("type") == "text"]
        if texts and any(t.strip() for t in texts):
            last = "\n".join(texts)
if last is None:
    print("NO FINAL TEXT", file=sys.stderr); sys.exit(1)
open(out, "w").write(last)
print(out, len(last), "chars")
