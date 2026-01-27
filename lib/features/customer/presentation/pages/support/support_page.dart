import 'package:flutter/material.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _messageController = TextEditingController();

  // Mock support tickets
  final List<_SupportTicket> _tickets = [
    _SupportTicket(
      id: 'TKT-001',
      subject: 'Delayed delivery inquiry',
      status: 'resolved',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      messages: [
        _Message(
          text: 'My order ORD-001 is delayed. Please help.',
          isUser: true,
        ),
        _Message(
          text:
              'We apologize for the delay. Your order is now in transit and will arrive by tomorrow.',
          isUser: false,
        ),
      ],
    ),
    _SupportTicket(
      id: 'TKT-002',
      subject: 'Pricing inquiry',
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      messages: [
        _Message(text: 'What are your rates for bulk shipments?', isUser: true),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactOptions(context),
          const SizedBox(height: 24),
          _buildFAQSection(context),
          const SizedBox(height: 24),
          _buildTicketsSection(context),
        ],
      ),
    );
  }

  Widget _buildContactOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Need Help?',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ContactCard(
                icon: Icons.phone,
                title: 'Call Us',
                subtitle: '+254 700 123 456',
                color: Colors.green,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling support...')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ContactCard(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'support@app.com',
                color: Colors.blue,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email...')),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ContactCard(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Available 24/7',
                color: Colors.purple,
                onTap: () => _showChatDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ContactCard(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Browse articles',
                color: Colors.orange,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening help center...')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      {
        'q': 'How do I track my order?',
        'a':
            'Go to the Tracking tab to see real-time updates on your shipment.',
      },
      {
        'q': 'What are your delivery times?',
        'a':
            'Standard delivery takes 1-3 business days depending on the destination.',
      },
      {
        'q': 'How do I cancel an order?',
        'a': 'You can cancel pending orders from the order details page.',
      },
      {
        'q': 'What payment methods do you accept?',
        'a': 'We accept M-Pesa, bank transfers, and credit/debit cards.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...faqs.map(
          (faq) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              title: Text(
                faq['q']!,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faq['a']!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Tickets',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: () => _showNewTicketDialog(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_tickets.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No support tickets',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ..._tickets.map((ticket) => _TicketCard(ticket: ticket)),
      ],
    );
  }

  void _showChatDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Live Chat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.support_agent,
                        size: 64,
                        color: Colors.green[300],
                      ),
                      const SizedBox(height: 16),
                      const Text('Connecting to support agent...'),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      if (_messageController.text.isNotEmpty) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message sent!')),
                        );
                        _messageController.clear();
                      }
                    },
                    icon: const Icon(Icons.send),
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewTicketDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Support Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ticket created successfully!')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportTicket {
  final String id;
  final String subject;
  final String status;
  final DateTime createdAt;
  final List<_Message> messages;

  _SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.createdAt,
    required this.messages,
  });
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}

class _TicketCard extends StatelessWidget {
  final _SupportTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isOpen = ticket.status == 'open';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isOpen
              ? Colors.orange.withValues(alpha: 0.1)
              : Colors.green.withValues(alpha: 0.1),
          child: Icon(
            isOpen ? Icons.pending_actions : Icons.check_circle,
            color: isOpen ? Colors.orange : Colors.green,
          ),
        ),
        title: Text(
          ticket.subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${ticket.id} • ${ticket.messages.length} messages'),
            Text(
              '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isOpen
                ? Colors.orange.withValues(alpha: 0.1)
                : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            ticket.status.toUpperCase(),
            style: TextStyle(
              color: isOpen ? Colors.orange : Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
