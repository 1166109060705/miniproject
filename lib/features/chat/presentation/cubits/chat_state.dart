import 'package:socialapp/features/chat/domain/entities/message.dart';

abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatMessagesLoaded extends ChatState {
  final List<Message> messages;
  ChatMessagesLoaded(this.messages);
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
}

class MessageSending extends ChatState {}

class MessageSent extends ChatState {}