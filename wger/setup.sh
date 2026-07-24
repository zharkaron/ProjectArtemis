#!/bin/bash
# wger superuser setup script
# Run this after containers are up: bash wger/setup.sh

set -e

echo "Waiting for wger-web to be healthy..."
until docker inspect --format='{{.State.Health.Status}}' wger-web 2>/dev/null | grep -q "healthy"; do
    sleep 5
done

echo "Creating superuser zharkaron..."
docker compose exec -T wger-web python3 manage.py shell << 'PYEOF'
from django.contrib.auth.models import User
if not User.objects.filter(username='zharkaron').exists():
    u = User.objects.create_superuser('zharkaron', 'zharkaron@zharkaron.lab', '^O$kSr&2*d2YLi')
    print('Superuser zharkaron created successfully')
else:
    u = User.objects.get(username='zharkaron')
    u.set_password('^O$kSr&2*d2YLi')
    u.save()
    print('Superuser zharkaron password reset')
print('Verify:', u.check_password('^O$kSr&2*d2YLi'))
PYEOF

echo "Setup complete! Login at workout.zharkaron.lab with:"
echo "  Username: zharkaron"
echo "  Password: ^O\$kSr&2*d2YLi"
